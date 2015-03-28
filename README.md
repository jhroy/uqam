# uqam
Extraction des contrats octroyés par l'UQAM ces dernières années.

Ce répertoire contient deux documents:

- **uqam.rb** : Un script pour extraire des infos relatives à l'UQAM dans les [documents sur les contrats publics téléchargeables à partir du portail de données ouvertes du gouvernement québécois](http://donnees.gouv.qc.ca/?node=/donnees-details&id=542483bf-3ea2-4074-b33c-34828f783995).
-  **uqam.csv** : Résultat du script, auquel j'ai manuellement fait les ajustements suivants:
  - ajout d'une colonne "Année financière"
  - traduction des montants en français (remplacement du point en virgule pour séparer les décimales)
  - ajout d'une colonne qui traduit les codes [UNSPSC (United Nations Standard Products and Services Code)](http://www.unspsc.org/) en une description en toutes lettres [selon le site du Système électronique des appels d'offres du gouvernement du Québec](https://formation.seao.ca/Recherche/ajouter_UNSPSC.aspx?Code=0).
