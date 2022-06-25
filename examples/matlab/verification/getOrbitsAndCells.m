function [orbits, cells, main, polar0, polar1] = getOrbitsAndCells(epoch_0, doRenew)

% Walker Constellation
% 
% There are a large number of constellations that may satisfy a
% particular mission. Usually constellations are designed so that the
% satellites have similar orbits, eccentricity and inclination so that
% any perturbations affect each satellite in approximately the same
% way. In this way, the geometry can be preserved without excessive
% station-keeping thereby reducing the fuel usage and hence increasing
% the life of the satellites. Another consideration is that the phasing
% of each satellite in an orbital plane maintains sufficient separation
% to avoid collisions or interference at orbit plane
% intersections. Circular orbits are popular, because then the satellite
% is at a constant altitude requiring a constant strength signal to
% communicate.
% 
% A class of circular orbit geometries that has become popular is the
% Walker Delta Pattern constellation. This has an associated notation to
% describe it which was proposed by John Walker.[1] His notation is:
% 
%     i: t/p/f
% 
% where: i is the inclination; t is the total number of satellites; p is
% the number of equally spaced planes; and f is the relative spacing
% between satellites in adjacent planes. The change in true anomaly (in
% degrees) for equivalent satellites in neighbouring planes is equal to
% f*360/t.
% 
% For example, the Galileo Navigation system is a Walker Delta
% 56°:27/3/1 constellation. This means there are 27 satellites in 3
% planes inclined at 56 degrees, spanning the 360 degrees around the
% equator. The "1" defines the phasing between the planes, and how they
% are spaced. The Walker Delta is also known as the Ballard rosette,
% after A. H. Ballard's similar earlier work.[2][3] Ballard's notation
% is (t,p,m) where m is a multiple of the fractional offset between
% planes.
% 
% Another popular constellation type is the near-polar Walker Star,
% which is used by Iridium. Here, the satellites are in near-polar
% circular orbits across approximately 180 degrees, travelling north on
% one side of the Earth, and south on the other. The active satellites
% in the full Iridium constellation form a Walker Star of 86.4°:66/6/2,
% i.e. the phasing repeats every two planes. Walker uses similar
% notation for stars and deltas, which can be confusing.
% 
% https://en.wikipedia.org/wiki/Satellite_constellation#Walker_Constellation
  
  if nargin < 2
    doRenew = 0;

  end % if

  % Read and save, or load orbits and cells data
  tic
  matFile = sprintf('simulation-verfication-orbits-cells-%.6f.mat', epoch_0);
  if ~exist(matFile) || doRenew
    disp('Reading orbits and cells data');
    
    % Load orbits and cells data
    % ncdisp('../system-planning-toolbox-ext-deps/dat/spacex/orbits-and-cells/388092.nc');
    % info = ncinfo('../system-planning-toolbox-ext-deps/dat/spacex/orbits-and-cells/388092.nc');
    dataDir = '../system-planning-toolbox-ext-deps/dat/spacex/orbits-and-cells';
    warning('off');
    allSatsICsJ2 = loadjson([dataDir, '/AllSatsInitialConditionsJ2.json']);
    warning('on');
    centerCoords = ncread([dataDir, '/388092.nc'], 'centerCoords');
    elementColor = ncread([dataDir, '/388092.nc'], 'elementColor');
    
    % allSatsICsJ2.constellation.regular_satellites.config
    %
    %                                                          fill_mode: 'all'
    %                                        initial_conditions_filename: [1x0 char]
    %                                                          num_planes: 32
    %                                           num_satellites_per_plane: 100
    %                                                   populated_planes: 'all'
    %                               reference_orbit_0x2E_apogee_altitude: 1150000
    %                reference_orbit_0x2E_argument_of_perigee_in_degrees: 0
    %                        reference_orbit_0x2E_inclination_in_degrees: 53
    %                              reference_orbit_0x2E_perigee_altitude: 1150000
    %    reference_orbit_0x2E_right_ascension_of_ascending_node_in_degre: 0
    %                      remove_precession_for_seamless_orbital_planes: 1
    %                                                     walker_phasing: 16
    %
    %                                              polar0_0x2E_fill_mode: 'all'
    %                            polar0_0x2E_initial_conditions_filename: [1x0 char]
    %                                             polar0_0x2E_num_planes: 6
    %                               polar0_0x2E_num_satellites_per_plane: 75
    %                                       polar0_0x2E_populated_planes: 'all'
    %                   polar0_0x2E_reference_orbit_0x2E_apogee_altitude: 1325000
    %    polar0_0x2E_reference_orbit_0x2E_argument_of_perigee_in_degrees: 0
    %            polar0_0x2E_reference_orbit_0x2E_inclination_in_degrees: 70
    %                  polar0_0x2E_reference_orbit_0x2E_perigee_altitude: 1325000
    %    polar0_0x2E_reference_orbit_0x2E_right_ascension_of_ascending_n: 0
    %          polar0_0x2E_remove_precession_for_seamless_orbital_planes: 1
    %                                         polar0_0x2E_walker_phasing: 1
    %
    %                                              polar1_0x2E_fill_mode: 'all'
    %                            polar1_0x2E_initial_conditions_filename: [1x0 char]
    %                                             polar1_0x2E_num_planes: 5
    %                               polar1_0x2E_num_satellites_per_plane: 75
    %                                       polar1_0x2E_populated_planes: 'all'
    %                   polar1_0x2E_reference_orbit_0x2E_apogee_altitude: 1275000
    %    polar1_0x2E_reference_orbit_0x2E_argument_of_perigee_in_degrees: 0
    %            polar1_0x2E_reference_orbit_0x2E_inclination_in_degrees: 81
    %                  polar1_0x2E_reference_orbit_0x2E_perigee_altitude: 1275000
    %    polar1_0x2E_reference_orbit_0x2E_right_ascension_of_ascending_n: 0
    %          polar1_0x2E_remove_precession_for_seamless_orbital_planes: 1
    %                                         polar1_0x2E_walker_phasing: 1
    %
    %                                        fill_mode_0x2E_plane_offset: 1
    %                                     max_off_nadir_angle_in_degrees: 50
    %                                                num_user_beam_types: 1
    %         user_beam_type0_0x2E_beam_beam_separation_angle_in_degrees: 4
    %                                         user_beam_type0_0x2E_count: 32
    %                   user_beam_type0_0x2E_gso_cutoff_angle_in_degrees: 12
    %    user_beam_type0_0x2E_gso_reducedpower_hi_cutoff_angle_in_degree: 80
    %    user_beam_type0_0x2E_gso_reducedpower_lo_cutoff_angle_in_degree: 25
    %              user_beam_type0_0x2E_half_power_beam_width_in_degrees: 2
    %                                          user_beam_type0_0x2E_name: '2 degree TX/RX pairs'
    %                            user_beam_type0_0x2E_service_slot_count: 4
    config = allSatsICsJ2.constellation.regular_satellites.config;
    
    % Re-assign configuration for main constellation
    main.num_planes                 = config.num_planes;
    main.num_satellites_per_plane   = config.num_satellites_per_plane;
    main.num_beams_per_satellite    = config.user_beam_type0_0x2E_count;
    main.orbit_apogee_altitude      = config.reference_orbit_0x2E_apogee_altitude;
    main.orbit_inclination          = config.reference_orbit_0x2E_inclination_in_degrees;
    main.orbit_perigee_altitude     = config.reference_orbit_0x2E_perigee_altitude;
    main.walker_phasing             = config.walker_phasing;
    
    % Re-assign configuration for polar 0 constellation
    polar0.num_planes               = config.polar0_0x2E_num_planes;
    polar0.num_satellites_per_plane = config.polar0_0x2E_num_satellites_per_plane;
    polar0.num_beams_per_satellite  = config.user_beam_type0_0x2E_count;
    polar0.orbit_apogee_altitude    = config.polar0_0x2E_reference_orbit_0x2E_apogee_altitude;
    polar0.orbit_inclination        = config.polar0_0x2E_reference_orbit_0x2E_inclination_in_degrees;
    polar0.orbit_perigee_altitude   = config.polar0_0x2E_reference_orbit_0x2E_perigee_altitude;
    polar0.walker_phasing           = config.polar0_0x2E_walker_phasing;
    
    % Re-assign configuration for polar 1 constellation
    polar1.num_planes               = config.polar1_0x2E_num_planes;
    polar1.num_satellites_per_plane = config.polar1_0x2E_num_satellites_per_plane;
    polar1.num_beams_per_satellite  = config.user_beam_type0_0x2E_count;
    polar1.orbit_apogee_altitude    = config.polar1_0x2E_reference_orbit_0x2E_apogee_altitude;
    polar1.orbit_inclination        = config.polar1_0x2E_reference_orbit_0x2E_inclination_in_degrees;
    polar1.orbit_perigee_altitude   = config.polar1_0x2E_reference_orbit_0x2E_perigee_altitude;
    polar1.walker_phasing           = config.polar1_0x2E_walker_phasing;
    
    % Change in right ascension between planes
    delta_Omega = (360 / main.num_planes) * (pi / 180);
    
    % Change in mean anomaly within a plane
    delta_M_in_plane = (360 / main.num_satellites_per_plane) * (pi / 180);
    
    % Change in initial mean anomaly between planes
    delta_M_0_between_planes = (main.walker_phasing * 360 ...
                                / (main.num_planes * main.num_satellites_per_plane)) * (pi / 180);
    
    % Initialize orbital elements
    a = 1 + ...
        ((main.orbit_apogee_altitude + ...
          main.orbit_perigee_altitude) / 2000) / EarthConstants.R_oplus; % Semi-major axis [er]
    e = (main.orbit_apogee_altitude - ...
         main.orbit_perigee_altitude) / ...
        (main.orbit_apogee_altitude + ...
         main.orbit_perigee_altitude); % Eccentricity [-]
    if e < 0.001
      e = 0.000001;

    end % if
    i = main.orbit_inclination * (pi / 180); % Inclination [rad]
    Omega = 0.0 * pi / 180; % Right ascension of the ascending node [rad]
    omega = 0.0 * pi / 180; % Argument of perigee [rad]
    M = 0.0 * pi / 180; % Mean anomaly [rad]
    epoch = epoch_0; % Epoch date number
    method = 'halley'; % Method to solve Kepler's equation: 'newton' or 'halley'
    
    % Construct and accumulate orbits by considering each plane ...
    nPln = main.num_planes;
    nSat = main.num_satellites_per_plane;
    orbits(nPln, nSat) = KeplerianOrbit();
    for iPln = 1:nPln
      Omega = Coordinates.check_wrap((iPln - 1) * delta_Omega);
      M_0 = (iPln - 1) * delta_M_0_between_planes;
      
      % ... and each satellite within a plane
      for iSat = 1:nSat
        M = Coordinates.check_wrap(M_0 + (iSat - 1) * delta_M_in_plane);
        orbits(iPln, iSat) = KeplerianOrbit(a, e, i, Omega, omega, M, epoch, method);
        
      end % for
      
    end % for
    
    % Find latitude and longitude of cells having a common color
    colorVal = 0;
    elementIdx = find(elementColor == colorVal);
    cells.varphi = centerCoords(2, elementIdx) * (pi / 180);
    cells.lambda = centerCoords(1, elementIdx) * (pi / 180);
    
    % Save orbits and cells data
    disp('Saving orbits and cells data');
    save(matFile);
    
  else
    
    % Load orbits and cells data
    disp('Loading orbits and cells data');
    load(matFile);
    
  end % if
  toc
  
end % getOrbitsAndCells()
