# CV

## Prérequis

- `texlive-base`
- `texlive-latex-recommended`
- `texlive-latex-extra` (enumitem, titlesec, paracol)
- `texlive-fonts-extra` (lato, fontawesome5)
- `texlive-lang-french`

Sur Arch Linux :

```bash
sudo pacman -S texlive-basic texlive-latexrecommended texlive-latexextra texlive-fontsextra texlive-langfrench
```

Sur Debian/Ubuntu :

```bash
sudo apt install texlive-base texlive-latex-recommended texlive-latex-extra texlive-fonts-extra texlive-lang-french
```

## Configuration

Copier le fichier d'exemple et remplir avec vos informations personnelles :

```bash
cp config/personal.tex.example config/personal.tex
```

Editer `config/personal.tex` avec vos informations (nom, email, telephone, etc.).

Ajouter votre photo au format PNG a la racine du projet sous le nom `photo.png`.

## Generation du PDF

```bash
pdflatex main.tex
```
