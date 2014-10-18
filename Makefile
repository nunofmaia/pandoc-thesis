PANDOC = pandoc
LATEX = pdflatex
BIBTEX = bibtex

SRCFORMAT = markdown+tex_math_dollars+tex_math_double_backslash+implicit_figures+citations

OUTDIR = out
INCLUDEDIR = include
PARTIALDIR = partials
FILTERSDIR = filters
STYLESDIR = styles
TMPDIR = $(OUTDIR)/tmp

RESOURCES = figures references.bib $(wildcard styles/*)

HEADER = header.md
TEMPLATE = template.md
DOCTITLE = thesis

all: clean markdown latex pdf
	@rm -rf $(BUILDDIR)
	@echo Done.

markdown:
	@echo Preparing markdown...
	@mkdir -p $(TMPDIR)
	@$(PANDOC) $(TEMPLATE) -t markdown --filter $(FILTERSDIR)/includes.hs > $(TMPDIR)/$(TEMPLATE)
	@cat $(HEADER) $(TMPDIR)/$(TEMPLATE) > $(OUTDIR)/$(DOCTITLE).md
	@rm -rf $(TMPDIR)

latex: markdown
	@echo Converting to LaTeX...
	@$(PANDOC) $(OUTDIR)/$(DOCTITLE).md \
      --from=$(SRCFORMAT) \
      --to=latex \
      --template=$(STYLESDIR)/llncs.template \
      --bibliography="references.bib" \
      --csl ./styles/splncs.csl \
      --natbib \
      --standalone \
      --smart \
      --number-sections \
      -o $(OUTDIR)/$(DOCTITLE).tex

pdf: latex
	@echo Generating pdf document...
	@mkdir -p $(TMPDIR)
	@cp -a $(RESOURCES) $(TMPDIR)
	@cp $(OUTDIR)/$(DOCTITLE).tex $(TMPDIR)
	@cd $(TMPDIR) && \
	$(LATEX) $(DOCTITLE) -interaction batchmode > /dev/null && \
	$(BIBTEX) $(DOCTITLE) > /dev/null && \
	$(LATEX) $(DOCTITLE) -interaction batchmode > /dev/null && \
	$(LATEX) $(DOCTITLE) -interaction batchmode > /dev/null
	@cp $(TMPDIR)/$(DOCTITLE).pdf $(OUTDIR)
	@rm -rf $(TMPDIR)

clean:
	@echo Removing last version...
	@if [ -d $(OUTDIR) ]; then rm -rf $(OUTDIR); fi
