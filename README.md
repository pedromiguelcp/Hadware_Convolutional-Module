<h1> Customizable FPGA-Based Hardware Accelerator for Standard Convolution Processes </h1>

<p> This work fits into the need to apply CNN-based solutions optimized for point cloud in devices with reduced resources. The design and implementation of a convolutional module were proposed to implement CNNs in hardware. In terms of configurability, it is possible to adjust all typical parameters and explore parallelism depending on the resource constraints, making it a solution capable of performing any convolution found in the literature. </p>

<h2 align="center">
    <img alt="Overall" title="Overall" src="Images/Overall.png" />
</h2>

<p> The module enables the configuration of the typical convolution parameters so it can be applied in any CNN layer. While the ReLU operation is default executed the user can enable the MaxPolling operation as a alternative of operations using stride.</p>

<h1 align="center">
    <img alt="Conv_ip" title="Conv_ip" src="Images/Conv_ip.png" />
</h1>

<p> The main focus during development was the energy efficiency. However, parallelism was also integrated to enable competitive processing times. Several Processing Elements can be triggered to increase throughput. The level of parallelism is conditioned by the amount of available resources in the target hardware platform.</p>

<h1 align="center">
    <img alt="Bram" title="Bram" src="Images/Bram.png" />
</h1>


<p> Each Processing element operates with high level of efficiency. For that a cascade processing was adopted in the processing unit core to perform the operations.</p>

<h3 align="center">
    <img alt="Master-cascade" title="Master-cascade" src="Images/Master-cascade.png" width="600"/>
</h3>

<p> As a case study, the convolutional module was integrated with the well-known 3D object detection model for both validation and evaluate the performance in a real case scenario.</p> 

<h3 align="center">
    <img alt="ConvM_validation_integration" title="ConvM_validation_integration" src="Images/ConvM_validation_integration.png" width="500"/>
</h3>

<p> Using the PointPillars model as a case study, the use of the module allowed to reduce the processing time up to 25% without compromising the detections performance.</p> 

<h3 align="center">
    <img alt="PP_6k" title="PP_6k" src="Images/PP_6k.png" width="700"/>
</h3>



<br>
<h4 align="center">
    Made by pedromiguelcp & duartesilva16. Project no longer under development. 🏁
    Checkout our article: https://www.mdpi.com/1424-8220/22/6/2184

    Contact me.pedropereira@gmail.com for more information!
</h4>