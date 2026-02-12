cd ~/Dropbox

cd "$HOME/Dropbox" || exit 1

# 1) Create a review list (no deletions). Excludes .dropbox cache internals.
OUT="$HOME/dropbox_junk_candidates_$(date +%Y%m%d_%H%M%S).txt"

find . \
  -path './.dropbox*' -prune -o \
  \( \
    -type d \( \
      -name '__pycache__' -o \
      -name '.pytest_cache' -o \
      -name '.mypy_cache' -o \
      -name '.ruff_cache' -o \
      -name '.pytype' -o \
      -name '.hypothesis' -o \
      -name '.tox' -o \
      -name '.nox' -o \
      -name '.eggs' -o \
      -name 'htmlcov' -o \
      -name '.ipynb_checkpoints' -o \
      -name '.venv' -o \
      -name 'venv' -o \
      -name '.pixi' -o \
      -name '.conda' -o \
      -name '.mamba' -o \
      -name 'conda-bld' -o \
      -name 'build' -o \
      -name 'dist' -o \
      -name 'node_modules' -o \
      -name '.parcel-cache' -o \
      -name '.next' -o \
      -name '.nuxt' -o \
      -name '.svelte-kit' -o \
      -name 'target' -o \
      -name '.cache' -o \
      -name '.Trash' -o \
      -name '.idea' -o \
      -name '.Rproj.user' -o \
      -path '*/renv/library' -o \
      -path '*/renv/staging' -o \
      -path '*/packrat/lib' -o \
      -name 'CMakeFiles' -o \
      -name 'cmake-build-*' \
    \) -print -o \
    -type f \( \
      -name '*.pyc' -o \
      -name '*.pyo' -o \
      -name '*.pyd' -o \
      -name '*.pyi.tmp' -o \
      -name '*.so.pyd' -o \
      -name '.coverage' -o \
      -name '.coverage.*' -o \
      -name '*.aux' -o \
      -name '*.bbl' -o \
      -name '*.bcf' -o \
      -name '*.blg' -o \
      -name '*.fdb_latexmk' -o \
      -name '*.fls' -o \
      -name '*.lof' -o \
      -name '*.log' -o \
      -name '*.lot' -o \
      -name '*.nav' -o \
      -name '*.out' -o \
      -name '*.run.xml' -o \
      -name '*.snm' -o \
      -name '*.synctex' -o \
      -name '*.synctex.gz' -o \
      -name '*.toc' -o \
      -name '*.vrb' -o \
      -name '*.xdv' -o \
      -name '*.o' -o \
      -name '*.obj' -o \
      -name '*.a' -o \
      -name '*.lib' -o \
      -name '*.la' -o \
      -name '*.lai' -o \
      -name '*.lo' -o \
      -name '*.slo' -o \
      -name '*.pch' -o \
      -name '*.gch' -o \
      -name '*.dll' -o \
      -name '*.dylib' -o \
      -name '*.so' -o \
      -name '*.mod' -o \
      -name 'CMakeCache.txt' -o \
      -name 'cmake_install.cmake' -o \
      -name '*.rlib' -o \
      -name '*.rmeta' -o \
      -name '*.pdb' -o \
      -name '*.exe' \
    \) -print \
  \) \
  | sed 's|^\./||' \
  | sort \
  > "$OUT"

printf 'Wrote candidate list: %s\n' "$OUT"
printf 'Counts by top-level folder:\n'
awk -F/ '{print $1}' "$OUT" | sort | uniq -c | sort -nr | sed -n '1,30p'



1) Preferred: find -exec rm -rf -- {} +
(avoids xargs edge cases; still efficient)

cd "$HOME/Dropbox" || exit 1

find . \
  -path './.dropbox*' -prune -o \
  \( -type d \( \
      -name '__pycache__' -o -name '.pytest_cache' -o -name '.mypy_cache' -o -name '.ruff_cache' -o \
      -name '.pytype' -o -name '.hypothesis' -o -name '.tox' -o -name '.nox' -o -name '.eggs' -o \
      -name 'htmlcov' -o -name '.ipynb_checkpoints' -o -name '.venv' -o -name 'venv' -o -name '.pixi' -o \
      -name '.conda' -o -name '.mamba' -o -name 'conda-bld' -o -name 'build' -o -name 'dist' -o \
      -name 'node_modules' -o -name '.parcel-cache' -o -name '.next' -o -name '.nuxt' -o -name '.svelte-kit' -o \
      -name 'target' -o -name '.cache' -o -name '.Trash' -o -name '.idea' -o -name '.Rproj.user' -o \
      -path '*/renv/library' -o -path '*/renv/staging' -o -path '*/packrat/lib' -o \
      -name 'CMakeFiles' -o -name 'cmake-build-*' \
    \) -print0 \) \
  -exec rm -rf -- {} +

2) Your suggestion: -print0 | xargs -0 -r rm -rf --
Works; just ensure you print only the directories you intend to delete (not both dirs and their contents).

cd "$HOME/Dropbox" || exit 1

find . \
  -path './.dropbox*' -prune -o \
  -type d \( \
      -name '__pycache__' -o -name '.pytest_cache' -o -name '.mypy_cache' -o -name '.ruff_cache' -o \
      -name '.pytype' -o -name '.hypothesis' -o -name '.tox' -o -name '.nox' -o -name '.eggs' -o \
      -name 'htmlcov' -o -name '.ipynb_checkpoints' -o -name '.venv' -o -name 'venv' -o -name '.pixi' -o \
      -name '.conda' -o -name '.mamba' -o -name 'conda-bld' -o -name 'build' -o -name 'dist' -o \
      -name 'node_modules' -o -name '.parcel-cache' -o -name '.next' -o -name '.nuxt' -o -name '.svelte-kit' -o \
      -name 'target' -o -name '.cache' -o -name '.Trash' -o -name '.idea' -o -name '.Rproj.user' -o \
      -path '*/renv/library' -o -path '*/renv/staging' -o -path '*/packrat/lib' -o \
      -name 'CMakeFiles' -o -name 'cmake-build-*' \
  \) -print0 \
| xargs -0 -r rm -rf --

Notes:
- Do NOT use -prune -print0 in the sense of printing pruned dirs; prune is for skipping traversal. You want -prune only for excluding .dropbox* (and any other keep trees).
- If you also want to delete file patterns (e.g., *.pyc, *.aux), do it in a separate find invocation (files only), to avoid redundant errors from deleting a directory and then its files.

Example for files-only cleanup:

cd "$HOME/Dropbox" || exit 1

find . \
  -path './.dropbox*' -prune -o \
  -type f \( \
    -name '*.pyc' -o -name '*.pyo' -o -name '*.pyd' -o -name '*.pyi.tmp' -o -name '*.so.pyd' -o \
    -name '.coverage' -o -name '.coverage.*' -o \
    -name '*.aux' -o -name '*.bbl' -o -name '*.bcf' -o -name '*.blg' -o -name '*.fdb_latexmk' -o -name '*.fls' -o \
    -name '*.lof' -o -name '*.log' -o -name '*.lot' -o -name '*.nav' -o -name '*.out' -o -name '*.run.xml' -o \
    -name '*.snm' -o -name '*.synctex' -o -name '*.synctex.gz' -o -name '*.toc' -o -name '*.vrb' -o -name '*.xdv' -o \
    -name '*.o' -o -name '*.obj' -o -name '*.a' -o -name '*.lib' -o -name '*.la' -o -name '*.lai' -o -name '*.lo' -o \
    -name '*.slo' -o -name '*.pch' -o -name '*.gch' -o -name '*.dll' -o -name '*.dylib' -o -name '*.so' -o -name '*.mod' -o \
    -name 'CMakeCache.txt' -o -name 'cmake_install.cmake' -o \
    -name '*.rlib' -o -name '*.rmeta' -o -name '*.pdb' -o -name '*.exe' \
  \) -print0 \
| xargs -0 -r rm -f --