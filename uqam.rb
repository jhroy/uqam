#!/usr/bin/env ruby
# ©2015 Jean-Hugues Roy. GNU GPL v3.

require "csv"
require "nokogiri"
require "open-uri"

# Création d'une variable contenant tous les fichiers XML qu'on a préalablement téléchargés du portail de données ouvertes du gouverenement (http://donnees.gouv.qc.ca/?node=/donnees-details&id=542483bf-3ea2-4074-b33c-34828f783995)  

fichiersInput = [
	"Avis_20090101_20091231.xml",
	"Avis_20100101_20101231.xml",
	"Avis_20110101_20111231.xml",
	"Avis_20120101_20121231.xml",
	"Avis_20130101_20130131.xml",
	"Avis_20130201_20130228.xml",
	"Avis_20130301_20130331.xml",
	"Avis_20130401_20130430.xml",
	"Avis_20130501_20130531.xml",
	"Avis_20130601_20130630.xml",
	"Avis_20130701_20130731.xml",
	"Avis_20130801_20130831.xml",
	"Avis_20130901_20130930.xml",
	"Avis_20131001_20131031.xml",
	"Avis_20131101_20131130.xml",
	"Avis_20131201_20131231.xml",
	"Avis_20140101_20140131.xml",
	"Avis_20140201_20140228.xml",
	"Avis_20140301_20140331.xml",
	"Avis_20140401_20140430.xml",
	"Avis_20140501_20140531.xml",
	"Avis_20140601_20140630.xml",
	"Avis_20140701_20140731.xml",
	"Avis_20140801_20140831.xml",
	"Avis_20140901_20140930.xml",
	"Avis_20141001_20141031.xml",
	"Avis_20141101_20141130.xml",
	"Avis_20141201_20141231.xml",
	"Avis_20150101_20150131.xml",
	"Avis_20150201_20150228.xml",
	"AvisRevisions_20140901_20140930.xml",
	"AvisRevisions_20141001_20141031.xml",
	"AvisRevisions_20141101_20141130.xml",
	"AvisRevisions_20141201_20141231.xml",
	"AvisRevisions_20150101_20150131.xml",
	"AvisRevisions_20150201_20150228.xml"
]

# Nom du fichier CSV qui sera créé à la fin

fichierOutput = "UQAM-contrats.csv"

# Initialisation d'une variable contenant

tout = []

# Boucle qui traite un à la fois les fichiers XML contenus dans la variable fichiersInput

fichiersInput.each do |fichierInput|

	page = Nokogiri::XML(open(fichierInput)) # On utilise la librairie Nokogiri pour extraire les données pertinentes des fichiers XML

	# On commence par compter le nombre total d'avis contenus dans le document

	(0..(page.xpath("//organisme").size)-1).each do |n|
		org = page.xpath("//organisme")[n].text
		if org[0..30] == "Université du Québec à Montréal" # Si on rencontre un avis émis par l'UQAM, on en extrait quelques données pertinentes
			
			puts "# " + n.to_s + " de " + fichierInput.to_s
			numSeao = page.xpath("//numeroseao")[n].text # Numéro unique défini par le SÉAO
			numContrat = page.xpath("//numero")[n].text # Numéro de contrat indiqué par l'UQAM
			titre = page.xpath("//titre")[n].text # Titre de l'avis, correspondant au travail exigé par le contrat
			date = page.xpath("//dateadjudication")[n].text # Date d'adjudication du contrat

			t = page.xpath("//type")[n].text # Le "type" nous informe des modalités d'octroi du contrat: avec ou sans appel d'offres.
			
			# Le type est un nombre qu'on traduit en texte avec "case" en se fiant aux spécifications définies dans le document suivant (http://donnees.gouv.qc.ca/geonetwork/srv/en/resources.get?uuid=542483bf-3ea2-4074-b33c-34828f783995&fname=SEAO-SpecificationsXML-DonneesOuvertes-20141201.pdf&access=private)

			case t
				when "3"
					type = "Contrat adjugé suite à un appel d'offres public"
				when "9"
					type = "Contrat octroyé de gré à gré"
				when "10"
					type = "Contrat adjugé suite à un appel d'offres sur invitations"
				when "14"
					type = "Contrat suite à un appel d'offres sur invitation publié au SEAO"
				when "16"
					type = "Contrat conclu relatif aux infrastructures de transport"
				when "17"
					type = "Contrat conclu - Appel d'offres public non publié au SEAO"
				end

			nat = page.xpath("//nature")[n].text # La nature du contrat

			# La nature est aussi exprimée par un code qu'on traduit en titre avec "case" en se fiant aux spécifications définies dans le document suivant (http://donnees.gouv.qc.ca/geonetwork/srv/en/resources.get?uuid=542483bf-3ea2-4074-b33c-34828f783995&fname=SEAO-SpecificationsXML-DonneesOuvertes-20141201.pdf&access=private)

			case nat
				when "1"
					nature = "Approvisionnements (biens)"
				when "2"
					nature = "Services"
				when "3"
					nature = "Travaux de construction"
				when "5"
					nature = "Autre"
				end

			code = page.xpath("//unspscprincipale")[n].text # Le code UNSPSC correspond à de grandes catégories définies par l'ONU pour classer les biens et services

			# On extrait ci-dessous la totalité du bloc "fournisseurs" de l'avis dans lequel on se trouve en ce moment

			fournisseurs = page.xpath("//fournisseurs")[n]
			
			nbFournisseurs = fournisseurs.css("fournisseur").size # On compte le nombre de soumissionnaires
			puts "Dans cet avis, il y a " + nbFournisseurs.to_s + " fournisseurs" # Affichage aux fins de vérification
			puts "."

			# Selon le nombre de soumissionnaires qu'on a comptés, on lance une boucle pour extraire des infos relatives à chacun

			(0..nbFournisseurs-1).each do |f|
				if fournisseurs.css("adjudicataire")[f].text == "1" # Si la variable "adjudicataire" est égale à "1", c'est que ce soumissionnaire est celui qui a obtenu le contrat
					# On va extraire les infos pertinentes et les mettre dans le "hash" "contrat"
					contrat = {}
					contrat["Date"] = date
					contrat["Titre"] = titre
					contrat["Fournisseur"] = fournisseurs.css("nomorganisation")[f].text
					contrat["Montant"] = (fournisseurs.css("montantcontrat")[f]).text.strip.to_f.round(2)
					contrat["Code UNSPSC"] = code
					contrat["Type"] = type
					contrat["Nature"] = nature
					contrat["Nb soumissionnaires"] = nbFournisseurs
					contrat["Numéro SEAO"] = numSeao
					contrat["Numéro de contrat UQAM"] = numContrat

					puts contrat # Affichages aux fins de vérification
					puts "="*50

					tout.push contrat # On ajoute les infos du contrat dans la variable qui contient les infos de tous les contrats
				end
			end

		end
	end

end

# Quand on a tout ramassé, on inscrit le tout dans un fichier CSV

CSV.open(fichierOutput, "wb") do |csv|
  csv << tout.first.keys
  tout.each do |hash|
    csv << hash.values
  end
end
