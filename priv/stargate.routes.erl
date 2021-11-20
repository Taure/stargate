#{prefix => "",
  security => false,
  routes => [
            {"/petapi", { stargate_main_controller, index}, #{methods => [get]}}
           ]
}.
