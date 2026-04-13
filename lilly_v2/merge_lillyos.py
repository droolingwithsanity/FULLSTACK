import os
import shutil

print("\n🧠 LillyOS FULL MERGE STARTING...\n")

SRC_A = "/root/recovery_lillyos/src"
SRC_B = "/root/lilly_v2/src"
DEST = "/root/LillyOS/src"

# -------------------------
# helper copy
# -------------------------
def copy_merge(src, dest):
    if not os.path.exists(src):
        return

    for root, dirs, files in os.walk(src):
        rel = os.path.relpath(root, src)
        target_dir = os.path.join(dest, rel)

        os.makedirs(target_dir, exist_ok=True)

        for f in files:
            src_file = os.path.join(root, f)
            dst_file = os.path.join(target_dir, f)

            # avoid overwriting newer OS files
            if os.path.exists(dst_file):
                print(f"⚠ skipping duplicate: {dst_file}")
                continue

            shutil.copy2(src_file, dst_file)
            print(f"✔ copied: {src_file} → {dst_file}")

# -------------------------
# merge both src trees
# -------------------------
print("📦 Merging recovery OS...")
copy_merge(SRC_A, DEST)

print("\n📦 Merging LLM UI brain...")
copy_merge(SRC_B, DEST)

print("\n🧠 Merge complete.\n")
