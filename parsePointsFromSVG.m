function [u, v] = parsePointsFromSVG(filename)

fid = fopen(filename);
magicword = '<g transform="translate(';
tline = fgetl(fid);
u = [];
v = [];
while ischar(tline)
    beginning = strfind(tline,magicword);
  if ~isempty(beginning)
    numStart = beginning+numel(magicword);
    commas = strfind(tline, ',')-1;
    firstnum = tline(numStart:commas(1));
    numEnd = strfind(tline, ')"')-1;
    secondnum = tline(commas(1)+2:numEnd);
    
    u(end+1) = str2double(firstnum); %#ok<*AGROW>
    v(end+1) = str2double(secondnum);
  end
  tline = fgetl(fid);
end

if isempty(u)
    warning(['Could not find points from ' filename]);
end

fclose(fid);

end
