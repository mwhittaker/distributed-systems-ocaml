# Edit this for your own project dependencies
OPAM_DEPENDS="ocamlfind core async cohttp menhir leveldb"

case "$OCAML_VERSION,$OPAM_VERSION" in
3.12.1,1.0.0) ppa=avsm/ocaml312+opam10 ;;
3.12.1,1.1.0) ppa=avsm/ocaml312+opam11 ;;
4.00.1,1.0.0) ppa=avsm/ocaml40+opam10 ;;
4.00.1,1.1.0) ppa=avsm/ocaml40+opam11 ;;
4.01.0,1.0.0) ppa=avsm/ocaml41+opam10 ;;
4.01.0,1.1.0) ppa=avsm/ocaml41+opam11 ;;
4.01.0,1.2.0) ppa=avsm/ocaml41+opam12 ;;
4.02.1,1.2.1) ppa=avsm/ocaml42+opam12 ;;
*) echo Unknown $OCAML_VERSION,$OPAM_VERSION; exit 1 ;;
esac

sudo apt-get install -y g++ libleveldb-dev libsnappy-dev
echo "yes" | sudo add-apt-repository ppa:$ppa
sudo apt-get update -qq
sudo apt-get install -qq ocaml ocaml-native-compilers camlp4-extra opam
export OPAMYES=1
export OPAMVERBOSE=1
echo OCaml version
ocaml -version
echo OPAM versions
opam --version
opam --git-version

opam init
opam update
opam upgrade
opam install ${OPAM_DEPENDS}
eval `opam config env`
make clean && \
make doc && \
sudo pip install ghp-import && \
ghp-import -n doc.docdir && \
git push -qf https://${TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git gh-pages
