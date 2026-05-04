Vehicle_GetExtraID(id)
{
	if(Iter_Contains(Vehicle, id))
		return VehicleData[id][cVehicle];

	return INVALID_VEHICLE_ID;
}