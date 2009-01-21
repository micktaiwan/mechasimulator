MENU = {

  :main => [['N', "N - Network", {:callback=>:display_network}],
            ['Q', "Q - Quit menu", {:go=>:quit}]],
  :display_network => [['Q', "Q - Back", {:go=>:main}]]
  
}
