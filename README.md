# CV

This repository generates my own CV/resume and is intended for personal use. Feel free to reuse the same approach to build your own CV for job applications.

## Requirements

- `texlive-base`
- `texlive-latex-recommended`
- `texlive-latex-extra` (enumitem, titlesec, paracol)
- `texlive-fonts-extra` (lato, fontawesome5)
- `texlive-lang-french`

On Arch Linux:

```bash
sudo pacman -S texlive-basic texlive-latexrecommended texlive-latexextra texlive-fontsextra texlive-langfrench
```

## Configuration

Copy the example file and fill it in with your personal information:

```bash
cp config/personal.tex.example config/personal.tex
```

Edit `config/personal.tex` with your information (name, email, phone, etc.).

Add your photo in PNG format at the project root under the name `photo.png`.

## Available versions

| Variant     | Source                | Description                                                    |
|-------------|-----------------------|------------------------------------------------------------------|
| `sidebar`   | `main.tex`            | Two columns: colored sidebar on the left (photo, contact, skills, languages, interests) |
| `onecolumn` | `main-onecolumn.tex`  | One column, sober, no photo: intended for large companies and ATS submissions |

Both variants share the same factual content (`sections/experience.tex`,
`sections/education.tex`, `sections/projects.tex`) as well as the color
palette and commands (`config/colors.tex`, `config/styles.tex`). Only the
layout (`config/layout/`) and the sections specific to each format differ.

## Generating the PDF

The `build.sh` script compiles the desired variant:

```bash
./build.sh                          # interactive menu
./build.sh sidebar                  # -> cv-sidebar.pdf
./build.sh onecolumn                # -> cv-onecolumn.pdf
./build.sh all                      # both
./build.sh onecolumn -o cv_name.pdf # custom output name
```

Intermediate files (`.aux`, `.log`, `.out`) are isolated in `build/`,
only the final PDF is written at the root.

The script systematically runs two `pdflatex` passes: the sidebar's
colored background is a TikZ `remember picture` overlay, whose position
is only known from the `.aux` file produced by the first compilation.

Equivalent manual compilation:

```bash
pdflatex main.tex && pdflatex main.tex                        # sidebar variant
pdflatex main-onecolumn.tex && pdflatex main-onecolumn.tex    # one-column variant
```
