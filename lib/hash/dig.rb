Hash.class_eval do
  def dig arg, *args
    x = self[arg]

    if !x.present?
      nil
    elsif args.empty?
      x
    else
      x.dig(*args)
    end
  end
end
