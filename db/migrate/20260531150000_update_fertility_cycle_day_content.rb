class UpdateFertilityCycleDayContent < ActiveRecord::Migration[8.1]
  def up
    local = Class.new(ActiveRecord::Base) do
      self.table_name = "cycle_day_contents"
      self.inheritance_column = nil
    end

    fertility = {
      1 => {s: "Fertility probability: 0-1% (extremely unlikely, except with very short cycles)",
            l: "With a very short cycle (21\u201324 days), a pregnancy is still unlikely, but not impossible, as ovulation could occur as early as day 7\u201310."},
      2 => {s: "Fertility probability: 0-1% (extremely unlikely, except with very short cycles)",
            l: "With a very short cycle (21\u201324 days), a pregnancy is still unlikely, but not impossible, as ovulation could occur as early as day 7\u201310."},
      3 => {s: "Fertility probability: 0-1% (extremely unlikely, except with very short cycles)",
            l: "With a very short cycle (21\u201324 days), a pregnancy is still unlikely, but not impossible, as ovulation could occur as early as day 7\u201310."},
      4 => {s: "Fertility probability: 1-3% (low, but possible with short cycles)",
            l: "With a very short cycle (21\u201324 days), a pregnancy is still unlikely, but not impossible, as ovulation could occur as early as day 7\u201310."},
      5 => {s: "Fertility probability: 1-3% (low, but possible with short cycles)",
            l: "With a short cycle of 21\u201324 days, early fertilization could be possible, as sperm can survive up to 5 days and ovulation could occur around day 7\u201310."},
      6 => {s: "Fertility probability: 5-10% (only relevant with short cycles, otherwise still very low)",
            l: "With a short cycle of 21\u201324 days, early fertilization could be possible, as sperm can survive up to 5 days and ovulation could occur around day 7\u201310."},
      7 => {s: "Fertility probability: 5-10% (only relevant with short cycles, otherwise still very low)",
            l: "With a short cycle of 21\u201324 days, early fertilization could be possible, as sperm can survive up to 5 days and ovulation could occur around day 7\u201310."},
      8 => {s: "Fertility probability: 10-20% (high with short cycles, moderate with longer cycles)"},
      9 => {s: "Fertility probability: 10-20% (high with short cycles, moderate with longer cycles)"},
      10 => {s: "Fertility probability: 30-50% (high, especially with medium-length cycles of 26\u201328 days)"},
      11 => {s: "Fertility probability: 30-50% (high, especially with medium-length cycles of 26\u201328 days)"},
      12 => {s: "Fertility probability: 50-80% (maximum with cycles of 26\u201330 days, as ovulation is imminent or has occurred)"},
      13 => {s: "Fertility probability: 50-80% (maximum with cycles of 26\u201330 days, as ovulation is imminent or has occurred)"},
      14 => {s: "Fertility probability: 50-80% (maximum with cycles of 26\u201330 days, as ovulation is imminent or has occurred)"},
      15 => {s: "Fertility probability: 70-90% (maximum chance of pregnancy with a regular cycle)"},
      16 => {s: "Fertility probability: 70-90% (maximum chance of pregnancy with a regular cycle)"},
      17 => {s: "Fertility probability: 20-40% (only still possible if ovulation occurred later than expected or sperm were already present)"},
      18 => {s: "Fertility probability: 20-40% (only still possible if ovulation occurred later than expected)"},
      19 => {s: "Fertility probability: 20-40% (only still possible if ovulation occurred later than expected)"},
      20 => {s: "Fertility probability: 5-10% (only relevant with very long cycles or late ovulation)"},
      21 => {s: "Fertility probability: 5-10% (only relevant with very long cycles or late ovulation)"},
      22 => {s: "Fertility probability: 0-1% (no new fertilization possible, only implantation of an already fertilized egg)"},
      23 => {s: "Fertility probability: 0-1% (no new fertilization possible, only implantation of an already fertilized egg)"},
      24 => {s: "Fertility probability: 0-1% (no new fertilization possible, only implantation of an already fertilized egg)"},
      25 => {s: "Fertility probability: 0-1% (no new fertilization possible, only implantation of an already fertilized egg)"},
      26 => {s: "Fertility probability: 0% (no more possibility for fertilization, except an already fertilized egg implants)"},
      27 => {s: "Fertility probability: 0% (no more possibility for fertilization, except an already fertilized egg implants)"},
      28 => {s: "Fertility probability: 0% (no more possibility for fertilization, except an already fertilized egg implants)"},
      29 => {s: "Fertility probability: 0% (no more possibility for fertilization, except an already fertilized egg implants)"},
      30 => {s: "Fertility probability: 0% (no more possibility for fertilization, except an already fertilized egg implants)"},
      31 => {s: "Fertility probability: 0% (no more possibility for fertilization, except an already fertilized egg implants)"},
      32 => {s: "Fertility probability: 0% (except a fertilized egg successfully implants, which then leads to pregnancy)"},
      33 => {s: "Fertility probability: 0% (except a fertilized egg successfully implants, which then leads to pregnancy)"},
      34 => {s: "Fertility probability: 0% (except a fertilized egg successfully implants, which then leads to pregnancy)"},
      35 => {s: "Fertility probability: 0% (except a fertilized egg successfully implants, which then leads to pregnancy)"}
    }

    fertility.each do |day, texts|
      rec = local.find_by(cycle_day: day, card_type: "fertility")
      next unless rec

      rec.update!(short_text: texts[:s], long_text: texts[:l] || texts[:s])
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
