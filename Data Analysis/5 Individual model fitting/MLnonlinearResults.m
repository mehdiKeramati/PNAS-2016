transferWeights = zeros (15,1);

transferWeights = [
0.615216257,
0.586871621,
0.228594458,
0.126352292,
0.248940735,
0.000652928,
0.740203451,
0.261038517,
0.290314258,
0.404249742,
0.264862897,
0.208964188,
0,
0.91155207,
0.677690525
];


figure('Position', [100, 100, 300, 300]);
bar (transferWeights);

figure('Position', [400, 100, 300, 300]);
hist (transferWeights);
