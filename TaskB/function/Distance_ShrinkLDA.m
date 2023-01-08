function [max_distance] = Distance_ShrinkLDA(model,featv)

max_distance = model.w*featv'+model.b;


end