function fFitness=calculateFitness(fObjV)
fFitness=zeros(size(fObjV));
ind=find(fObjV>=0);
fFitness(ind)=1./(fObjV(ind)+1);
ind=find(fObjV<0);
fFitness(ind)=1+abs(fObjV(ind));
