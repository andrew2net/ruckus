require 'csv'

class ProfilesStat
  def export
    CSV.generate do |csv|
      csv << data.fields
      coupon_id_index = data.fields.index('coupon_id')

      coupon_ids = data.values.collect { |line| line[coupon_id_index] }
      coupons_hash = {}

      Coupon.where(id: coupon_ids).each do |coupon|
        coupons_hash[coupon.id] ||= coupon
      end

      data.values.each do |line|
        new_line = line

        if line[coupon_id_index].present?
          coupon_code = coupons_hash[line[coupon_id_index].to_i].code
          new_line[coupon_id_index] = coupon_code
        end

        csv << new_line
      end
    end
  end

  private

  def query
    <<-SQL
      SELECT
        accounts.email                          AS email,
        profiles.id                             AS id,
        profiles.TYPE                           AS type,
        profiles.name                           AS name,
        profiles.party_affiliation              AS party_affiliation,
        profiles.office                         AS office,
        profiles.city                           AS city,
        profiles.state                          AS state,
        profiles.address_1                      AS address_1,
        profiles.address_2                      AS address_2,
        profiles.district                       AS district,
        profiles.contact_zip                    AS contact_zip, (
          CASE
            WHEN profiles.donations_on AND de_accounts.is_active_on_de THEN 'Yes'
            ELSE 'No'
          END
        )                                       AS donations_on,
        donats.donations_amount                 AS donations_amount,
        donats.donations_count                  AS donations_count,
        events.events_count                     AS events_count,
        issues.issues_count                     AS issues_count,
        media.media_count                       AS media_count,
        press.press_count                       AS press_count, (
          CASE
            WHEN credit_card_holders.token IS NOT NULL OR profiles.premium_by_default THEN 'Yes'
            ELSE 'No'
          END
        )                                       AS premium, (
          CASE
            WHEN  profiles.premium_by_default THEN 'Yes'
            ELSE 'No'
          END
        )                                       AS premium_by_default, (
          CASE
            WHEN profiles.suspended THEN 'Yes'
            ELSE 'No'
          END
        )                                       AS suspended,
        visits.visits_count                     AS visits_count,
        coupons.id                              AS coupon_id,
        date_trunc('hour', profiles.created_at) AS created_at,
        date_trunc('hour', accounts.last_sign_in_at) AS last_visit
      FROM
        profiles
        LEFT JOIN ownerships          ON ownerships.profile_id = profiles.id
        LEFT JOIN accounts            ON accounts.id = ownerships.account_id
        LEFT JOIN de_accounts         ON profiles.id = de_accounts.profile_id
        LEFT JOIN credit_card_holders ON profiles.id = credit_card_holders.profile_id
        LEFT JOIN coupons             ON credit_card_holders.coupon_id = coupons.id
        LEFT JOIN (
          SELECT SUM(amount) AS donations_amount, COUNT(id) AS donations_count, profile_id
          FROM donations
          GROUP BY profile_id
        ) donats                      ON donats.profile_id = profiles.id
        LEFT JOIN (
          SELECT COUNT(id) AS press_count, profile_id FROM press_releases GROUP BY profile_id
        ) press                       ON press.profile_id = profiles.id
        LEFT JOIN (
          SELECT COUNT(id) AS events_count, profile_id FROM events GROUP BY profile_id
        ) events                      ON events.profile_id = profiles.id
        LEFT JOIN (
          SELECT COUNT(id) AS issues_count, profile_id FROM issues GROUP BY profile_id
        ) issues                      ON issues.profile_id = profiles.id
        LEFT JOIN (
          SELECT COUNT(id) AS media_count, profile_id FROM media GROUP BY profile_id
        ) media                       ON media.profile_id = profiles.id
        LEFT JOIN (
          SELECT COUNT(requests.id) AS visits_count, profile_id
          FROM requests, domains
          WHERE requests.requestable_id = domains.id AND requests.requestable_type = 'Domain'
          GROUP BY profile_id
        ) visits                      ON visits.profile_id = profiles.id
      WHERE profiles.id IN (SELECT credit_card_holders.profile_id
        FROM credit_card_holders WHERE credit_card_holders.token IS NOT NULL AND profile_id IS NOT NULL)
        OR profiles.premium_by_default = true
      ORDER BY accounts.id, profiles.id
    SQL
  end

  def data
    @data ||= ActiveRecord::Base.connection.execute(query)
  end
end
