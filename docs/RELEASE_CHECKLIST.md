# Release Checklist

## Build
- [ ] Flutter analyze passes
- [ ] Flutter tests pass
- [ ] Android release build passes
- [ ] iOS release build passes
- [ ] App signing configured

## Backend
- [ ] Supabase migration applied
- [ ] RLS policies reviewed with real roles
- [ ] Storage buckets/policies configured
- [ ] Edge Functions deployed for privileged operations
- [ ] Database backups/retention configured
- [ ] Realtime enabled only where required

## Maps/GPS
- [ ] Production tile provider configured
- [ ] Routing/geocoding provider configured
- [ ] Attribution/license requirements satisfied
- [ ] Background location permissions reviewed
- [ ] Stale/offline GPS states tested

## 3D
- [ ] Licensed GLB assets for all trailer types
- [ ] Asset LOD/compression validated
- [ ] State variants validated on target Android/iOS devices
- [ ] Missing asset blocks release rather than silently faking a model

## Workflows
- [ ] Driver onboarding
- [ ] Document upload/expiry
- [ ] Trip booking race test
- [ ] Loading arrival proof
- [ ] Delay policy calculation
- [ ] Loading/unloading transitions
- [ ] Delivery proof
- [ ] Trip completion
- [ ] Maintenance
- [ ] Notifications

## Reports
- [ ] Truck report filters correctly
- [ ] Driver report filters correctly
- [ ] Trip/shipment reports correct
- [ ] PDF A4/RTL/LTR/page numbers
- [ ] XLSX opens in Excel/Sheets
- [ ] Scheduled reports run from server

## Security
- [ ] No service-role key in app
- [ ] RLS negative tests pass
- [ ] Storage path isolation tested
- [ ] Audit logs verified
- [ ] Input validation and file limits tested
