"""Version-pinned compiler table inputs for the pipeline scheduler.

Performance-table IDs are a separate namespace from LLO opcodes. Callers must
supply a reviewed classification, consumer footprint and resource namespace.
No inference from a mnemonic or an XProf display name happens here.
"""
import json
from pathlib import Path
import re

from .pipeline import Operation, ResourceHold


class CompilerCosts:
    def __init__(self, table, *, binary_sha256):
        if table.get('schema_version') != 1 or table.get('target') != 'gf':
            raise ValueError('unsupported compiler cost schema/target')
        if not isinstance(binary_sha256, str) or not re.fullmatch(r'[0-9a-f]{64}', binary_sha256):
            raise ValueError('compiler binary SHA256 is required')
        if binary_sha256 != table.get('binary_sha256'):
            raise ValueError('compiler binary identity does not match cost table')
        self.binary_sha256 = binary_sha256
        if table.get('id_space') != 'GF performance-table Instruction; NOT LloOpcode':
            raise ValueError('unknown instruction ID namespace')
        self.provenance = f"libtpu {table['libtpu_version']} GF table; sha256={binary_sha256}"
        self.resource_count = table['resource_count']
        if type(self.resource_count) is not int or self.resource_count <= 0:
            raise ValueError('invalid resource count')
        self.rows = {}
        for row in table['rows']:
            identity, latency = row['id'], row['latency_cycles']
            if type(identity) is not int or identity < 0 or identity in self.rows:
                raise ValueError('duplicate or invalid performance ID')
            if type(latency) is not int or not 0 <= latency < 2**31:
                raise ValueError('invalid latency')
            resources = {}
            for key, cycles in row['resource_values'].items():
                if not isinstance(key, str) or not key.isdecimal() or str(int(key)) != key:
                    raise ValueError('invalid resource index')
                resource = int(key)
                if not 0 <= resource < self.resource_count or type(cycles) is not int or not 0 <= cycles < 2**31:
                    raise ValueError('invalid resource value')
                resources[resource] = cycles
            self.rows[identity] = (latency, resources)
        if set(self.rows) != set(range(table['row_count'])):
            raise ValueError('incomplete compiler table')

    @classmethod
    def read(cls, path, *, binary_sha256):
        return cls(json.loads(Path(path).read_text()), binary_sha256=binary_sha256)

    def operation(self, operation_id, performance_id, *, issue_footprint,
                  resource_namespace, classification_source, depends_on=()):
        """Bind a table row with explicit consumer checks; refuse guessed IDs."""
        if type(performance_id) is not int or performance_id not in self.rows:
            raise ValueError('unknown performance-table ID')
        if not isinstance(resource_namespace, str) or not resource_namespace:
            raise ValueError('resource namespace is required')
        if not isinstance(classification_source, str) or not classification_source:
            raise ValueError('classification/footprint provenance is required')
        if not isinstance(issue_footprint, (list, tuple)):
            raise ValueError('explicit issue footprint is required')
        if any(type(r) is not int or not 0 <= r < self.resource_count for r in issue_footprint):
            raise ValueError('invalid issue footprint')
        latency, resources = self.rows[performance_id]
        prefix = resource_namespace + '.gf.resource.'
        return Operation(
            operation_id, f'GF performance ID {performance_id} [{classification_source}]', latency,
            depends_on=tuple(depends_on),
            resource_holds=tuple(ResourceHold(prefix + str(r), cycles)
                                 for r, cycles in sorted(resources.items()) if cycles),
            issue_checks=tuple(prefix + str(r) for r in sorted(set(issue_footprint))))
