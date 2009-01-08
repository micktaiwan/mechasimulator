object
  20.times do |i|
    p(i*0.1,0, 3)
    string :last_two # do nothing if only one last element
  end
  fix   :first
  motor :last, :first, [0,0,1], 1
end_object

gravity :all

follow :last, {:distance=>4, :side=>1}
# à cause du frustrum qui est à 1.5, on ne voit pas les objects si on est à moins de 1.5 de eux
# donc si tu veux voir le point que tu suit,il faut le suivre à > 1.5 de distance

