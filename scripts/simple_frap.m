% Copyright (C) 2018 University of Dundee & Open Microscopy Environment.
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without modification, 
% are permitted provided that the following conditions are met:
% 
% Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.
% Redistributions in binary form must reproduce the above copyright notice, 
% this list of conditions and the following disclaimer in the documentation
% and/or other materials provided with the distribution.
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
% ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
% OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
% IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
% INCIDENTAL, SPECIAL, EXEMPLARY OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
% HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
% (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
% OF THE POSSIBILITY OF SUCH DAMAGE.

% The script has been tested with Matlab2017a

host='workshop.openmicroscopy.org';
% To be modified
user='USERNAME';
password='PASSWORD';
datasetId = 23953;

client = loadOmero(host);
client.enableKeepAlive(60);
% Create an OMERO session
session = client.createSession(user, password);
% Initiliaze the service used to load the Regions of Interest (ROI)
service = session.getRoiService();

% Retrieve the Dataset with the Images
dataset = getDatasets(session, datasetId, true);
images = toMatlabList(dataset.linkedImageList);

% Iterate through the images

for i = 1 : numel(images)
    image = images(i);
    imageId = image.getId().getValue();
    pixels = image.getPrimaryPixels();
    sizeT = pixels.getSizeT().getValue(); % The number of timepoints

    % Load the ROIs linked to the Image. Only keep the Ellipses
    roiResult = service.findByImage(imageId, []);
    rois = roiResult.rois;
    if rois.size == 0
        continue;
    end
    toAnalyse = java.util.ArrayList;
    for thisROI  = 1:rois.size
        roi = rois.get(thisROI-1);
        for ns = 1:roi.sizeOfShapes
            shape = roi.getShape(ns-1);
            if (isa(shape, 'omero.model.Ellipse'))
                toAnalyse.add(java.lang.Long(shape.getId().getValue()));
            end
        end
    end

    % We analyse the first z and the first channel
    keys = strings(1, sizeT);
    values = strings(1, sizeT);
    means = zeros(1, sizeT);
    for t = 0:sizeT-1
        % OMERO index starts at 0
        stats = service.getShapeStatsRestricted(toAnalyse, 0, t, [0]);
        calculated = stats(1,1);
        mean = calculated.mean(1,1);
        index = t+1;
        keys(1, index) = num2str(t);
        values(1, index) = num2str(mean);
        means(1, index) = mean;
    end
    disp(means)
    % create a map annotation and link it to the Image
    mapAnnotation = writeMapAnnotation(session, cellstr(keys), cellstr(values), 'namespace', 'demo.simple_frap_data');
    linkAnnotation(session, mapAnnotation, 'image', imageId);

    % Create a CSV
    headers = 'Image_name,ImageID,Timepoint,Mean';
    tmpName = [tempname,'.csv'];
    [filepath,imageName,ext] = fileparts(tmpName);
    f = fullfile(filepath, 'results_frap.csv');
    fileID = fopen(f,'w');
    fprintf(fileID,'%s\n',headers);
    for j = 1 : numel(keys)
        row = strcat(char(imageName), ',', num2str(imageId), ',', keys(1, j), ',', values(1, j));
        fprintf(fileID,'%s\n',row);
    end
    fclose(fileID);
    % Create a file annotation
    fileAnnotation = writeFileAnnotation(session, f, 'mimetype', 'text/csv', 'namespace', 'training.demo');
    linkAnnotation(session, fileAnnotation, 'image', imageId);

    % Plot the result
    time = 1:sizeT;
    fig = plot(means);
    xlabel('Timepoint'), ylabel('Values');
    % Save the plot as png
    name = strcat(char(image.getName().getValue()),'_FRAP_plot.png');
    saveas(fig,name);
    % Upload the Image as an attachment
    fileAnnotation = writeFileAnnotation(session, name);
    linkAnnotation(session, fileAnnotation, 'image', imageId);
    % Delete the local file
    delete(name)
    
end
disp("Done");
client.closeSession();
