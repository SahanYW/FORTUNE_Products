export type CLIENT = {
	
	ListPadding: number;
	GridColumns: number;
	GridPadding: number;
	
	ViewportCameraAngle: number;
	RotationTime: number;
	ReturnTime: number;
	DefaultFov: number;
	HoverFov: number;
}

export type SERVER = {
	SpawnerCooldown: number;
	MaxCarsPerPlayer: number;
	SpawnerDistance: number;
	
	TransparencyLimit: number;
	AutoDeleteObjects: { [number]: string };
	ObjectExceptions: { [number]: string };
}

export type CONFIG = {
	Client: CLIENT;
	Server: SERVER;
}

return nil