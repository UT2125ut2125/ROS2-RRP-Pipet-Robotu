clc;
clear;
close all;

% Gazebo ve Octave karsilastirma verilerini oku
dosya = '/home/ummahantemel/pipet_final_ws/gazebo_karsilastirma_10.csv';

veri = dlmread(dosya, ',', 1, 0);

konum = veri(:,1);

% Koordinatlar
teorik = veri(:,5:7);
gazebo = veri(:,8:10);

% Hata (metreden milimetreye)
hata_mm = veri(:,11) * 1000;

ortalama_mm = mean(hata_mm);
std_mm = std(hata_mm);

% GRAFIK 1: Konum hatalari
figure(1);

bar(konum, hata_mm);

hold on;

plot([0.5 10.5], ...
     [ortalama_mm ortalama_mm], ...
     'r--', 'LineWidth', 2);

grid on;

xlabel('Konfigurasyon Numarasi');
ylabel('Oklid Konum Hatasi (mm)');
title('R-R-P Pipet Robotu - 10 Konfigurasyon Hata Analizi');

legend('Konum Hatasi', 'Ortalama Hata');

set(gca, 'XTick', 1:10);

print('/home/ummahantemel/pipet_final_ws/hata_grafigi.png', ...
      '-dpng', '-r200');

% GRAFIK 2: Teorik ve Gazebo X, Y, Z
figure(2);

plot(konum, teorik(:,1), 'b-o', 'LineWidth', 2);
hold on;
plot(konum, gazebo(:,1), 'b--x', 'LineWidth', 1.5);

plot(konum, teorik(:,2), 'r-o', 'LineWidth', 2);
plot(konum, gazebo(:,2), 'r--x', 'LineWidth', 1.5);

plot(konum, teorik(:,3), 'g-o', 'LineWidth', 2);
plot(konum, gazebo(:,3), 'g--x', 'LineWidth', 1.5);

grid on;

xlabel('Konfigurasyon Numarasi');
ylabel('Pipet Ucu Konumu (m)');
title('Teorik ve Gazebo Koordinat Karsilastirmasi');

legend('Teorik X', 'Gazebo X', ...
       'Teorik Y', 'Gazebo Y', ...
       'Teorik Z', 'Gazebo Z');

set(gca, 'XTick', 1:10);

print('/home/ummahantemel/pipet_final_ws/koordinat_karsilastirma.png', ...
      '-dpng', '-r200');

fprintf('\n========== SONUCLAR ==========\n');

fprintf('Ortalama hata: %.6f mm\n', ortalama_mm);
fprintf('Standart sapma: %.6f mm\n', std_mm);

fprintf('\nGrafikler basariyla kaydedildi.\n');
