header_image <- fluidPage(
  tags$style(
    "
        .centered-image {
          display: flex;
          justify-content: center;
          align-items: center;
        }
        "
  ),
  
  # Wrap the image in a div with the 'centered-image' class
  tags$div(class = "centered-image", 
           tags$img(src = "haha.jpg", height = "200px"))
)