# Registry v1. All validation precedes filesystem use.
def fields($required; $optional):
  type == "object" and ((keys - ($required + $optional)) | length == 0)
  and (($required - keys) | length == 0);
def nickname: type == "string" and test("^[a-z][a-z0-9_-]*$");
def nonempty: type == "string" and length > 0;
def clean: nonempty and (test("[\\\\\u0000-\u001f\u007f]") | not);
def filename: clean and (contains("/") | not) and . != "." and . != "..";
def path: clean and (split("/") | all(. != "" and . != "." and . != ".."));
def fp: type == "string" and test("^SHA256:[A-Za-z0-9+/]{43}$");
def unique_items: length == (unique | length);
def integer: type == "number" and floor == .;
def datevalid:
  type == "string" and test("^[0-9]{4}-[0-9]{2}-[0-9]{2}$") and
  ((split("-") | map(tonumber)) as $d |
    $d[0] >= 1 and $d[1] >= 1 and $d[1] <= 12 and $d[2] >= 1 and
    $d[2] <= ([31,(if ($d[0]%4==0 and ($d[0]%100!=0 or $d[0]%400==0)) then 29 else 28 end),31,30,31,30,31,31,30,31,30,31][$d[1]-1]));
def timestamp:
  type == "string" and test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$")
  and (.[0:10] | datevalid) and (.[11:13] | tonumber) < 24
  and (.[14:16] | tonumber) < 60 and (.[17:19] | tonumber) < 60;
def nullable($filter): . == null or $filter;
def destination:
  fields(["kind","host","account","repository","ssh_alias","verification_status","verified_at","revocation_status","revoked_at"]; ["evidence"])
  and (.kind | IN("server","account","deploy_key"))
  and (.host | type == "string" and test("^[A-Za-z0-9][A-Za-z0-9._:-]*$"))
  and (.account | nullable(nonempty)) and (.repository | nullable(nonempty))
  and (.ssh_alias | nullable(nonempty)) and (.evidence | nullable(type == "string"))
  and (.verification_status | IN("unverified","verified"))
  and (.revocation_status | IN("not_started","pending","completed"))
  and (.verified_at | nullable(timestamp)) and (.revoked_at | nullable(timestamp))
  and (if .verification_status == "verified" then .account != null and .verified_at != null and (.kind != "deploy_key" or .repository != null) else .verified_at == null end)
  and (.kind == "deploy_key" or .repository == null)
  and (if .revocation_status == "completed" then .revoked_at != null and (.evidence | nonempty) else .revoked_at == null end);
def holder($devices):
  fields(["device","path","private_key_expected","material_state","observed_at"]; [])
  and (.device as $d | $devices | has($d)) and (.path | path)
  and (.private_key_expected | type == "boolean")
  and (.material_state | IN("present","archived","removed","unknown"))
  and (.observed_at | nullable(timestamp));
def record($devices):
  fields(["name","fingerprint","purpose","status","holders","created","review_after_months","backup","replaces","authorization_scope_complete","notes","authorized"]; [])
  and (.name | filename) and (.fingerprint | fp) and (.purpose | nickname)
  and (.status | IN("active","retiring","retired"))
  and (.holders | type == "array" and all(holder($devices)))
  and (.created | nullable(datevalid))
  and (.review_after_months | nullable(integer and . > 0))
  and (.backup | nullable(type == "string")) and (.replaces | nullable(fp))
  and (.authorization_scope_complete | type == "boolean") and (.notes | type == "string")
  and (.authorized | type == "array" and all(destination)
    and (map([.kind,.host,.account,.repository]) | unique_items))
  and (.status != "retired" or (.authorization_scope_complete and (.authorized | all(.revocation_status == "completed"))));
def chain($records; $id; $seen):
  if $id == null then true
  elif ($seen | index($id)) != null then false
  else chain($records; $records[$id].replaces; $seen + [$id]) end;
. as $root |
if (fields(["version","devices","keys"]; []) and .version == 1 and (.version | integer)
  and (.devices | type == "object" and (keys | all(nickname)) and
    all(.[]; fields(["hostnames","provisioning"]; [])
      and (.hostnames | type == "array" and unique_items and all(type == "string" and test("^[a-z0-9][a-z0-9_-]*$")))
      and (.provisioning | IN("unprovisioned","inventoried")))
    and ([.[].hostnames[]] | unique_items))
  and (.keys | type == "array" and all(record($root.devices)))
  and ([.keys[].fingerprint] | unique_items)
  and ([.keys[].holders[] | [.device,.path]] | unique_items)
  and ((.keys | map({key:.fingerprint,value:.}) | from_entries) as $records |
    all($root.keys[]; .replaces as $r | $r == null or ($r != .fingerprint and ($records | has($r))))
    and all($root.keys[]; chain($records; .fingerprint; []))))
then $root else error("registry does not satisfy v1 contract") end
