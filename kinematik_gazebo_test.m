clc;
clear;

% ROBOT TEKNOLOJILERI - RRP PIPET ROBOTU
% 10 konfigürasyonlu Gazebo kinematik testi

Q = csvread('/home/ummahantemel/pipet_final_ws/octave_kinematik_10.csv');

N = rows(Q);
veri = zeros(N, 11);

for i = 1:N

    q1 = Q(i,1);
    q2 = Q(i,2);
    d3 = Q(i,3);

    fprintf('\n========== KONUM %d / 10 ==========\n', i);

    % ROS 2 action komutuyla robotu hareket ettir
    cmd = sprintf( ...
      ['timeout 35 ros2 action send_goal ' ...
       '/arm_controller/follow_joint_trajectory ' ...
       'control_msgs/action/FollowJointTrajectory ' ...
       '"{trajectory: {joint_names: [joint1, joint2, joint3], ' ...
       'points: [{positions: [%.6f, %.6f, %.6f], ' ...
       'time_from_start: {sec: 5}}]}}"'], ...
       q1, q2, d3);

    [durum, cevap] = system(cmd);

    if durum != 0 || isempty(strfind(cevap, 'SUCCEEDED'))
        error('Konum %d hareketi basarisiz: %s', i, cevap);
    endif

    % Gazebo dinamik konum bilgisini oku
    [durum, ham] = system( ...
      ['timeout 6 gz topic -e ' ...
       '-t /world/empty/dynamic_pose/info ' ...
       '| grep -m 1 -A 10 carriage_link']);

    if durum != 0
        error('Konum %d Gazebo verisi okunamadi.', i);
    endif

    % carriage_link konumunu ayikla
    blok = regexp(ham, ...
      'name:\s*"carriage_link"[\s\S]*?position\s*\{([^}]*)\}', ...
      'tokens', 'once');

    if isempty(blok)
        error('carriage_link bulunamadi. Ham veri: %s', ham);
    endif

    poz = blok{1};
    g = zeros(1,3);
    eksenler = {'x','y','z'};

    for j = 1:3
        ifade = [eksenler{j} ':\s*([-+0-9.eE]+)'];
        bulunan = regexp(poz, ifade, 'tokens', 'once');

        if !isempty(bulunan)
            g(j) = str2double(bulunan{1});
        endif
    endfor

    % Gazebo tasiyici koordinatindan tool0 koordinatina
    g(3) = g(3) - 0.215;

    % Octave teorik ileri kinematik
    t = [
      0.22*cos(q1) + 0.18*cos(q1+q2), ...
      0.22*sin(q1) + 0.18*sin(q1+q2), ...
      0.085-d3
    ];

    % Oklid hatasi
    hata = norm(t-g);

    veri(i,:) = [i, q1, q2, d3, t, g, hata];

    fprintf('Octave : %.8f  %.8f  %.8f\n', t);
    fprintf('Gazebo : %.8f  %.8f  %.8f\n', g);
    fprintf('Hata   : %.10f metre\n', hata);

endfor

% Istatistik
hatalar = veri(:,11);

ortalama = mean(hatalar);
standart_sapma = std(hatalar);

fprintf('\n========== GENEL SONUCLAR ==========\n');
fprintf('Ortalama hata: %.10f metre\n', ortalama);
fprintf('Standart sapma: %.10f metre\n', standart_sapma);

% CSV kaydet
dosya = '/home/ummahantemel/pipet_final_ws/gazebo_karsilastirma_10.csv';

fid = fopen(dosya, 'w');

fprintf(fid, ...
'No,q1_rad,q2_rad,d3_m,Teorik_X,Teorik_Y,Teorik_Z,Gazebo_X,Gazebo_Y,Gazebo_Z,Hata_m\n');

for i = 1:N
    fprintf(fid, ...
      '%d,%.10f,%.10f,%.10f,%.10f,%.10f,%.10f,%.10f,%.10f,%.10f,%.12f\n', ...
      veri(i,:));
endfor

fclose(fid);

fprintf('\nSONUC DOSYASI: %s\n', dosya);
fprintf('10 KONFIGURASYON TESTI TAMAMLANDI.\n');
