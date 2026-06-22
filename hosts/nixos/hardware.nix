{
	config,
	lib,
	pkgs,
	...
}: {
	# ── NVIDIA (PRIME sync, Optimus) ─────────────────────────────────────────────
	services.xserver.videoDrivers = ["modesetting" "nvidia"];
	hardware.nvidia = {
		modesetting.enable = true;
		nvidiaSettings = true;
		open = false;
		package = config.boot.kernelPackages.nvidiaPackages.stable;
	};
	hardware.nvidia.prime = {
		sync.enable = true;
		intelBusId = "PCI:0:2:0";
		nvidiaBusId = "PCI:1:0:0";
	};

	# ── Intel VAAPI (integrated GPU) ─────────────────────────────────────────────
	hardware.graphics = {
		enable = true;
		enable32Bit = true;
		extraPackages = with pkgs; [
			libva
			libva-utils
			intel-media-driver
			libva-vdpau-driver
			libvdpau-va-gl
		];
	};
	environment.variables.LIBVA_DRIVER_NAME = "iHD";
}
