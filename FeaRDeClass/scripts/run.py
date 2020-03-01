from pca import PCA
from api import BaseballData
import numpy as np
import sys
import random
import matplotlib.pyplot as plt
from scipy.stats import zscore

def project_vecs(anls, vecs, eig_count):
    # project the data in vecs onto a specific number of eigenvectors in anls
    assert eig_count <= anls.ndim
    eigs = anls.V[:, :eig_count]

    #print("Selected eigenvectors shape", eigs.shape)
    #print("Shape of vectors to be projected", vecs.shape)

    return np.matmul(eigs.transpose(), vecs)

def generate_plot(data_api, title, anls, tests, ids, ids_tests):
    # plots the top two vectors by 
    player_space = project_vecs(anls, anls.vectors, 3)

    salaries = []
    for pid in ids:
        salaries.append(data_api.get_mean_log_salary(pid))

    print("Log Salaries: Mean", np.mean(salaries), "Standard deviation", np.std(salaries))

    cm = plt.cm.get_cmap('RdYlBu')
    sc = plt.scatter(player_space[0, :], player_space[1, :], c=salaries, s=2, cmap=cm)
    plt.colorbar(sc, label="Log10(Player Salary ($))")
    plt.title("Player Salary by " + title + " Performance Features")
    plt.xlabel("Principal Component #1")
    plt.ylabel("Principal Component #2")
    plt.show()

def get_rms(data_api, eig_count, anls, tests, ids, ids_tests):
    # run the classifier on the supplied data and return rms salary error
    close_count = 20 #number of closest players of which to average salaries
    close_sals = np.zeros(shape=(close_count,))

    player_space = project_vecs(anls, anls.vectors, eig_count)
    tests_projected = project_vecs(anls, tests, eig_count)

    print("Using", tests.shape[1], "test values.")

    sse = 0 # sum of squared errors

    missing = 0

    for i in range(tests.shape[1]):
        diffs = player_space - tests_projected[:, i].reshape((eig_count, 1))
        dists = np.linalg.norm(diffs, axis=0) # distance to each column vector in player_space

        least = np.argsort(dists)[0:close_count] # index of closest vector in face space

        # average the salaries of the nearest 5 points in player space
        for j in range(close_count):
            least_id = ids[least[j]]
            close_sals[j] = data_api.get_mean_log_salary(least_id)
            close_sals[j] = np.nan if close_sals[j] == 0 else close_sals[j]

        l_salary = np.nanmean(close_sals)
        salary = data_api.get_mean_log_salary(ids_tests[i])

        if (l_salary == 0) or (l_salary == np.nan) or (salary == 0):
            # salary data is missing for one or more of the relevant players
            #print("Salary error! least_id", least_id, "ids_tests[i]", ids_tests[i], "l_salary", l_salary, "salary", salary)
            missing += 1
        else:
            sse += (l_salary - salary) ** 2

    return (sse/(tests.shape[1] - missing)) ** 0.5


def get_pca(data_api):
    player_ids = data_api.players().tolist()
    entry_count = len(player_ids)
    player_ids = list(set(player_ids))

    # get the column names for the three categories of statistics
    stat_names_pit = data_api.get_player_pitching('salech01').columns[5:].tolist() # hardcoded :(
    stat_names_bat = data_api.get_player_batting(player_ids[0]).columns[5:].tolist()
    stat_names_fld = data_api.get_player_fielding(player_ids[0]).columns[6:].tolist()

    # build seperate arrays for pitchers and non-pitchers.
    #pit_stats = np.array([[]])
    pit_stats = np.empty((entry_count, len(stat_names_pit)))
    bat_stats = np.empty((2 * entry_count, len(stat_names_bat)))
    fld_stats = np.empty((3 * entry_count, len(stat_names_fld)))

    pit_tests = np.empty((0, len(stat_names_pit)))
    bat_tests = np.empty((0, len(stat_names_bat)))
    fld_tests = np.empty((0, len(stat_names_fld)))

    ids_pit = []
    ids_bat = []
    ids_fld = []

    ids_pit_tests = []
    ids_bat_tests = []
    ids_fld_tests = []

    pstat_idx = 0
    bstat_idx = 0
    fstat_idx = 0

    print("Filling out statistic arrays (", len(player_ids), " ids)...")
    for pidx in range(len(player_ids)):
        pid = player_ids[pidx]
        print(pidx)
        temp = data_api.get_player_pitching(pid)
        if (random.random() < 0.99):
            # Add to the train set
            if temp is not None:
                pit = temp.to_numpy()[:, 5:]
                ln = pit.shape[0]
                if ln:
                    pit_stats[pstat_idx : pstat_idx + ln, :] = pit
                    pstat_idx += ln
                #pit_stats = np.append(pit_stats, pit, axis=0)
                ids_pit += [pid] * ln
            # Collate batting data
            bat = data_api.get_player_batting(pid).to_numpy()[:, 5:]
            ln = bat.shape[0]
            if ln:
                bat_stats[bstat_idx : bstat_idx + ln, :] = bat
                bstat_idx += ln
            #bat_stats = np.append(bat_stats, bat, axis=0)
            ids_bat += [pid] * ln
            # Collate fielding data
            fld = data_api.get_player_fielding(pid).to_numpy()[:, 6:]
            ln = fld.shape[0]
            if ln:
                fld_stats[fstat_idx : fstat_idx + ln, :] = fld
                fstat_idx += ln
            #fld_stats = np.append(fld_stats, fld, axis=0)
            ids_fld += [pid] * fld.shape[0]
        else:
            # Add to the test set
            if temp is not None:
                pit = temp.to_numpy()[:, 5:]
                pit_tests = np.append(pit_tests, pit, axis=0)
                ids_pit_tests += [pid] * pit.shape[0]
            # Collate batting data
            bat = data_api.get_player_batting(pid).to_numpy()[:, 5:]
            bat_tests = np.append(bat_tests, bat, axis=0)
            ids_bat_tests += [pid] * bat.shape[0]
            # Collate fielding data
            fld = data_api.get_player_fielding(pid).to_numpy()[:, 6:]
            fld_tests = np.append(fld_tests, fld, axis=0)
            ids_fld_tests += [pid] * fld.shape[0]
        sys.stdout.write("\033[F")
    print("Done.")

    pit_stats = pit_stats[:pstat_idx, :]
    bat_stats = bat_stats[:bstat_idx, :]
    fld_stats = fld_stats[:fstat_idx, :]

    print("Cleaning data ...")
    # Replace nans in the dataset with the column mean

    pit_stats = pit_stats.astype(np.float64)
    bat_stats = bat_stats.astype(np.float64)
    fld_stats = fld_stats.astype(np.float64)

    pit_stats = np.where(np.isnan(pit_stats), np.ma.array(pit_stats, 
        mask = np.isnan(pit_stats)).mean(axis = 0), pit_stats) 
    bat_stats = np.where(np.isnan(bat_stats), np.ma.array(bat_stats, 
        mask = np.isnan(bat_stats)).mean(axis = 0), bat_stats)
    fld_stats = np.where(np.isnan(fld_stats), np.ma.array(fld_stats, 
        mask = np.isnan(fld_stats)).mean(axis = 0), fld_stats)

    # Same cleaning but for the test arrays
    pit_tests = pit_tests.astype(np.float64)
    bat_tests = bat_tests.astype(np.float64)
    fld_tests = fld_tests.astype(np.float64)

    pit_tests = np.where(np.isnan(pit_tests), np.ma.array(pit_tests, 
        mask = np.isnan(pit_tests)).mean(axis = 0), pit_tests) 
    bat_tests = np.where(np.isnan(bat_tests), np.ma.array(bat_tests, 
        mask = np.isnan(bat_tests)).mean(axis = 0), bat_tests)
    fld_tests = np.where(np.isnan(fld_tests), np.ma.array(fld_tests, 
        mask = np.isnan(fld_tests)).mean(axis = 0), fld_tests)

    # Convert tests to column vectors for later processing
    pit_tests = pit_tests.transpose()
    bat_tests = bat_tests.transpose()
    fld_tests = fld_tests.transpose()

    # normalize all vectors
    pit_stats = zscore(pit_stats, axis=1)
    bat_stats = zscore(bat_stats, axis=1)
    fld_stats = zscore(fld_stats, axis=1)

    pit_tests = zscore(pit_tests, axis=1)
    bat_tests = zscore(bat_tests, axis=1)
    fld_tests = zscore(fld_tests, axis=1)

    print("Nans? ", np.any(np.isnan(pit_stats)))
    print("Infs? ", np.any(np.isinf(pit_stats)))

    print("Done.")

    # the pca objects take column vectors:
    print("Running PCA ...")
    #pit_anls = PCA(np.transpose(pitcher_stats), labels=(stat_names_pit + stat_names_bat + stat_names_fld))
    #nop_anls = PCA(np.transpose(nopitch_stats), labels=(stat_names_bat + stat_names_fld))
    pit_anls = PCA(np.transpose(pit_stats), labels=stat_names_pit)
    bat_anls = PCA(np.transpose(bat_stats), labels=stat_names_bat)
    fld_anls = PCA(np.transpose(fld_stats), labels=stat_names_fld)

    pit_anls.find_eigens()
    bat_anls.find_eigens()
    fld_anls.find_eigens()
    print("Done.")

    pit_out = (pit_anls, pit_tests, ids_pit, ids_pit_tests)
    bat_out = (bat_anls, bat_tests, ids_bat, ids_bat_tests)
    fld_out = (fld_anls, fld_tests, ids_fld, ids_fld_tests)

    return (pit_out, bat_out, fld_out)

def main():
    random.seed(47)

    print("Importing player data ...")
    data_api = BaseballData(startyear=2000, endyear=2016)
    print("Done.")

    po, bo, fo = get_pca(data_api)

    print("Top pitcher features:")
    po[0].print_eigens(num=2)
    print("Top batter features:")
    bo[0].print_eigens(num=2)
    print("Top fielder features")
    fo[0].print_eigens(num=2)

    print("Running test values through player-space ...")
    print("Pitching ...")
    rms_pit = get_rms(data_api, 5, *po)
    print("Done.")
    print("Batting ...")
    rms_bat = get_rms(data_api, 5, *bo)
    print("Done.")
    print("Fielding ...")
    rms_fld = get_rms(data_api, 5, *fo)
    print("Done.")
    print("Done.")

    print("Pitching-based salary estimation RMS: ", rms_pit)
    print("Batting-based  salary estimation RMS: ", rms_bat)
    print("Fielding-based salary estimation RMS: ", rms_fld)

    print("Generating plots ...")
    generate_plot(data_api, "Pitching", *po)
    generate_plot(data_api, "Batting", *bo)
    generate_plot(data_api, "Fielding", *fo)
    print("Done.")

if __name__ == '__main__':
    main()
