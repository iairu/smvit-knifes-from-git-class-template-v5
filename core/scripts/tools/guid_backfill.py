#!/usr/bin/env python3
import sys, uuid, pathlib, io, re

# Malý parser YAML frontmatteru bez externých balíkov
FM_RE = re.compile(r"^---\n(.*?)\n---\n", re.DOTALL)

def parse_frontmatter(text):
    m = FM_RE.match(text)
    if not m:
        return {}, text, None
    raw = m.group(1)
    body = text[m.end():]
    data = {}
    for line in raw.splitlines():
        if not line.strip() or line.strip().startswith("#"):
            continue
        # jednoduché kľúč: hodnota (bez hlbokých štruktúr)
        if ":" in line:
            k, v = line.split(":", 1)
            k = k.strip()
            v = v.strip()
            # odstraň úvodzovky
            if v.startswith('"') and v.endswith('"'):
                v = v[1:-1]
            if v.startswith("'") and v.endswith("'"):
                v = v[1:-1]
            data[k] = v
    return data, body, m

def dump_frontmatter(data, body):
    # zachováme jednoduché poradie kľúčov (id → guid → dao → …)
    keys_order = ["id","guid","dao","title","description","author","authors","status","tags","slug","sidebar_label","sidebar_position","locale","created","modified"]
    keys = [k for k in keys_order if k in data] + [k for k in data if k not in keys_order]
    buf = io.StringIO()
    buf.write("---\n")
    for k in keys:
        v = data[k]
        if isinstance(v, str):
            # ak obsahuje dvojbodku alebo medzeru, dáme úvodzovky bezpečne
            if ":" in v or "#" in v or v.strip() != v:
                buf.write(f'{k}: "{v}"\n')
            else:
                buf.write(f"{k}: \"{v}\"\n")
        else:
            buf.write(f'{k}: "{v}"\n')
    buf.write("---\n")
    buf.write(body)
    return buf.getvalue()

def process_file(mdpath: pathlib.Path):
    text = mdpath.read_text(encoding="utf-8")
    data, body, m = parse_frontmatter(text)
    if not data:
        # bez frontmatteru – nič nerobíme
        return False

    changed = False
    if "dao" not in data or not str(data["dao"]).strip():
        data["dao"] = "knife"
        changed = True

    if "guid" not in data or not str(data["guid"]).strip():
        kid = data.get("id", "").strip() or "KXXX"
        data["guid"] = f"knife-{kid}-{uuid.uuid4()}"
        changed = True

    if changed:
        new_text = dump_frontmatter(data, body)
        mdpath.write_text(new_text, encoding="utf-8")
    return changed

def main():
    if len(sys.argv) < 2:
        print("Usage: guid_backfill.py <docs_root>", file=sys.stderr)
        sys.exit(2)

    docs_root = pathlib.Path(sys.argv[1])
    count = 0
    for md in docs_root.rglob("index.md"):
        if "/knifes/" in str(md).replace("\\","/"):
            if process_file(md):
                count += 1
    print(f"[guid_backfill] Updated files: {count}")

if __name__ == "__main__":
    main()