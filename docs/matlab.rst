Analyze OMERO data using MATLAB
===============================

Matlab is a powerful programming platform. We show here you can analyze data stored in OMERO using Matlab.

We will use  \ https://docs.openmicroscopy.org/latest/omero/developers/Matlab.html\  as a reference.

Description
-----------

Here we demonstrate how to analyze a batch of images associated with the paper \ `Subdiffraction imaging of centrosomes reveals higher-order organizational features of pericentriolar material <https://www.nature.com/articles/ncb2591>`__\ .

We will show:

-  How to connect to OMERO using MATLAB.
-  How to load data (dataset, channels information, binary data).
-  How to analyze images. The channel’s name will be used to determine the channel to analyze.
-  How to save the generated ROIs to OMERO.
-  How to save the results stored in a CSV file locally back to the OMERO.server as a FileAnnotation.
-  How to convert the CSV file into an OMERO.table.

Setup
-----

Please read first :doc:`setup`.

Resources
---------

We will use:

-  Images from IDR `idr0021 <https://idr.openmicroscopy.org/search/?query=Name:idr0021>`_.

For convenience, the IDR data have been imported into the training
OMERO.server. This is **only** because we **cannot** save results back to IDR
which is a read-only OMERO.server.

Step-by-Step
------------

The script used in this document is :download:`idr0021_steps.m <../scripts/idr0021_steps.m>`.

#. In the *EDITOR* tab create a new script:

   .. image:: images/matlab2.png

#. Copy the code for the exercises from :download:`idr0021_steps.m <../scripts/idr0021_steps.m>`

#. Paste it into the new file and save the script under whatever name you like. **DO NOT RUN** the whole script.

#. To follow along the exercises only select the code block of each exercise and run it with "Evaluate Selection":

   .. image:: images/matlab3.png

#. Later exercises cannot be run unless the previous exercises have been executed successfully.

#. If **you get stuck**, right-click on the *Workspace* tab, clear the workspace and start again from the beginning:

   .. image:: images/matlab4.png

**Exercise 1**
~~~~~~~~~~~~~~

**Objectives:** Connect to OMERO and print out your group ID.

**Steps:**

-  Replace the USER and PASSWORD placeholders with your assigned credentials.

-  Select the code block of **Exercise 1**

-  Run it with “Evaluate Selection”.

**Exercise 2**
~~~~~~~~~~~~~~

**Objectives:** Load dataset and list the images contained in the dataset.

**Steps:**

-  In OMERO.web find the dataset ‘matlab-dataset’ (in Project ‘matlab-project’)

-  Copy its ID

-  In the matlab code replace DATASET_ID with this ID

-  Run the code block.

**Exercise 3**
~~~~~~~~~~~~~~

**Objectives:** Read metadata; in particular find out which protein is the target in the images by looking through the image’s map annotations (key-value pairs). It is the same protein for all four sample images.

**Steps:**

-  Select one image from the dataset

-  Load the map annotation linked to the image

-  Select the entry whose key is 'Antibody Target'

**Exercise 4**
~~~~~~~~~~~~~~

**Objectives:** Find out in which channels the target protein is stained.

**Steps:**

-  Iterate through the dataset

-  For each Image

   -  Find the channel’s name using the LogicalChannel

   -  Determine the index of the channel whose name matches the value found in the previous exercise

**Exercise 5**
~~~~~~~~~~~~~~

**Objectives:** Perform a simple image segmentation on one image and display the result.

**Steps:**

-  Iterate through the dataset

-  Analyze the image whose name is *siControl_N20_Cep215_I_20110411_Mon-1509_0_SIR_PRJ.dv*

-  Retrieve the plane with ``z=0, t=0, c=channel-1``. Indexes start at `0` in OMERO.

-  Determine the mean, the standard deviation.

**Exercise 6**
~~~~~~~~~~~~~~

**Objectives:** Perform the image segmentation on the whole dataset and save the results as ROIs and CSV file. The CSV file is saved as a FileAnnotation

**Exercise 7**
~~~~~~~~~~~~~~

**Objectives:** Save the results as OMERO.table. This shows how to convert the CSV file into an OMERO.table

**Steps:** 

-  Run the code

-  Go back to OMERO.web

-  Select an image from the evaluated dataset

-  Expand the *Tables* harmonica. You should see the results there.

-  Double-click on the thumbnail of the image and inspect the ROIs in OMERO.iviewer.

-  Note: You can also use OMERO.parade on the OMERO.table data created in this manner. As OMERO.parade works only on Projects, in OMERO.web

   -  Create a new Project

   -  Put the analyzed Dataset into that Project

   -  Attach the OMERO.table created in **Exercise 7** to the Project

   -  Now you can use OMERO.parade on the Project
