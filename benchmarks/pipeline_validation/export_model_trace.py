"""Export the unified model's selected kernel bundle issues as a Chrome trace."""
import argparse
import gzip
import json
from pathlib import Path


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--bundles',type=Path,required=True)
    p.add_argument('--model',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args();b=json.loads(a.bundles.read_text());m=json.loads(a.model.read_text())
    a.output.parent.mkdir(parents=True,exist_ok=True)
    count=0
    with gzip.open(a.output,'wt') as out:
        out.write('{"traceEvents":[{"ph":"M","pid":1,"tid":1,"name":"thread_name","args":{"name":"Model bundle issue / wait"}}')
        for address,start,end,ids in b['bundles']:
            if not address.startswith('0:0x97/'):continue
            e=dict(ph='X',pid=1,tid=1,name=address,ts=start/b['frequency_hz']*1e6-m['kernel_origin_us'],
                   dur=(end-start)/b['frequency_hz']*1e6,args=dict(opcodes=[b['opcodes'][i] for i in ids],
                   semantics='modeled bundle issue/wait interval; not execution duration'))
            out.write(','+json.dumps(e,separators=(',',':')));count+=1
        out.write('],"displayTimeUnit":"ns"}')
    print('Exported',count,'model bundle events',a.output)


if __name__=='__main__':main()
