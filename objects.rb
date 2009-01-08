object
  fix p(0,0,1)
  p(3,0,1)
  string :last_two 
  
  motor :last, [0,0,0], [0,0,1], 1
end_object

follow :last, {:distance=>1.51}
# à cause du frustrum qui est à 1.5, on ne voit pas les objects si on est à moins de 1.5 de eux
# donc si tu veux voir le point que tu suit,il faut le suivre à > 1.5 de distance



