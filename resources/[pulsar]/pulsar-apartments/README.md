# Pulsar Framework Custom Apartments

Pulsar-native rebuild of the custom Mythic apartment system.

## Current Scope

- Uses Pulsar exports and callbacks instead of legacy framework components.
- Stores apartment assignments in HeidiSQL via `apartment_assignments`.
- Keeps `characters.Apartment` synchronized for Pulsar spawn and police systems.
- Builds apartment rooms from `shared/config.lua`.
- Supports room entry, exit, stash, wardrobe, logout, reception assignment, elevators, entry requests, police raid target, and showers.
- Imports missing `apt_room_*` room doors into `ox_doorlock`.
- Syncs assigned room owners into `ox_doorlock` by updating each room door's `characters` list.

## Swap Notes

This folder is intentionally named `Pulsar Framework Custom Apartments` while under development. When ready, stop/remove the stock `pulsar-apartments` resource and rename or move this resource into the live `pulsar-apartments` slot so existing Pulsar resources continue calling `exports['pulsar-apartments']`.

The SQL table is auto-created on resource start. The matching manual SQL is also in `apartment_assignments.sql`.

Apartment room doors are loaded from `shared/apartment_doors.lua`. Their names must match each room's `doorId` in `shared/config.lua` such as `apt_room_100`.
