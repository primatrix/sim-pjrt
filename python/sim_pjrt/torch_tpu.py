"""Bootstrap TorchTPU on a CPU host using the simulator's PJRT client."""


def initialize():
    # TorchTPU's automatic loader checks PCI hardware before registering the
    # backend. Explicit registration is needed on a host with no physical TPU.
    from torch_tpu import _loader
    from torch_tpu._internal.device import _device_ops_backend

    _loader._init_device("tpu")
    # Initialize PJRT so subsequent availability/device-count queries use the
    # simulated client rather than the physical PCI device count.
    # Unlike set_device_index(), this propagates client initialization failures.
    _device_ops_backend._get_device_count()


def synchronize():
    import torch

    torch.accelerator.synchronize()
