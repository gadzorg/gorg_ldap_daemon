class MockupGramAccount

  attr_reader :id,
              :uuid,
              :hruid,
              :id_soce,
              :enabled,
              :lastname,
              :firstname,
              :birthname,
              :birth_firstname,
              :email,
              :gapps_email,
              :birthdate,
              :deathdate,
              :gender,
              :is_gadz,
              :is_student,
              :school_id,
              :is_alumni,
              :date_entree_ecole,
              :date_sortie_ecole,
              :ecole_entree,
              :buque_texte,
              :buque_zaloeil,
              :gadz_fams,
              :gadz_fams_zaloeil,
              :gadz_proms_principale,
              :gadz_proms_secondaire,
              :avatar_url,
              :description,
              :url

  def initialize(id: nil, uuid: nil, hruid: nil, id_soce: nil, enabled: nil, lastname: nil, firstname: nil, birthname: nil, birth_firstname: nil, email: nil, gapps_email: nil, birthdate: nil, deathdate: nil, gender: nil, is_gadz: nil, is_student: nil, school_id: nil, is_alumni: nil, date_entree_ecole: nil, date_sortie_ecole: nil, ecole_entree: nil, buque_texte: nil, buque_zaloeil: nil, gadz_fams: nil, gadz_fams_zaloeil: nil, gadz_proms_principale: nil, gadz_proms_secondaire: nil, avatar_url: nil, description: nil, url: nil)
    @id=id
    @uuid=uuid
    @hruid=hruid
    @id_soce=id_soce
    @enabled=enabled
    @lastname=lastname
    @firstname=firstname
    @birthname=birthname
    @birth_firstname=birth_firstname
    @email=email
    @gapps_email=gapps_email
    @birthdate=birthdate
    @deathdate=deathdate
    @gender=gender
    @is_gadz=is_gadz
    @is_student=is_student
    @school_id=school_id
    @is_alumni=is_alumni
    @date_entree_ecole=date_entree_ecole
    @date_sortie_ecole=date_sortie_ecole
    @ecole_entree=ecole_entree
    @buque_texte=buque_texte
    @buque_zaloeil=buque_zaloeil
    @gadz_fams=gadz_fams
    @gadz_fams_zaloeil=gadz_fams_zaloeil
    @gadz_proms_principale=gadz_proms_principale
    @gadz_proms_secondaire=gadz_proms_secondaire
    @avatar_url=avatar_url
    @description=description
    @url=url
  end

end