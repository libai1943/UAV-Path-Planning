function  cir_plot(c,r)

    cir_x=[];
    cir_y=[];
    for j=0:pi/500:2*pi
        aa_x= r*cos(j)+c(1);
        aa_y= r*sin(j)+c(2);
        cir_x=[cir_x,aa_x];
        cir_y=[cir_y,aa_y];
    end
    plot(cir_x,cir_y,'k--','LineWidth',1.5);

