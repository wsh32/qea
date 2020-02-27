from pca import PCA
from api import BaseballData
import numpy as np
import sys
import random

def project_vecs(anls, vecs, eig_count):
	# project the data in vecs onto a specific number of eigenvectors in anls
	assert eig_count <= anls.ndim
	eigs = anls.V[:, :eig_count]

	print("Selected eigenvectors shape", eigs.shape)
	print("Shape of vectors to be projected", vecs.shape)

	return np.matmul(eigs.transpose(), vecs)

def get_rms(data_api, eig_count, anls, tests, ids, ids_tests):
	# run the classifier on the supplied data and return rms salary error

	player_space = project_vecs(anls, anls.vectors, eig_count)
	tests_projected = project_vecs(anls, tests, eig_count)

	sse = 0 # sum of squared errors

	for i in range(tests.shape[1]):
		diffs = player_space - tests_projected[:, i].reshape((eig_count, 1))
		dists = np.linalg.norm(diffs, axis=0) # distance to each column vector in player_space

		least = np.argsort(dists)[0] # index of closest vector in face space
		least_id = ids[least]

		l_salary = data_api.get_mean_salary(least_id)
		salary = data_api.get_mean_salary(ids_tests[i])
		#print("least_id", least_id, "ids_tests[i]", ids_tests[i])

		sse += (l_salary - salary) ** 2

	return (sse/tests.shape[1]) ** 0.5


def get_pca(data_api):
	player_ids = data_api.players().tolist()

	# get the column names for the three categories of statistics
	stat_names_pit = data_api.get_player_pitching('salech01').columns[5:].tolist() # hardcoded :(
	stat_names_bat = data_api.get_player_batting(player_ids[0]).columns[5:].tolist()
	stat_names_fld = data_api.get_player_fielding(player_ids[0]).columns[6:].tolist()

	# build seperate arrays for pitchers and non-pitchers.
	#pit_stats = np.array([[]])
	pit_stats = np.empty((0, len(stat_names_pit)))
	bat_stats = np.empty((0, len(stat_names_bat)))
	fld_stats = np.empty((0, len(stat_names_fld)))

	pit_tests = np.empty((0, len(stat_names_pit)))
	bat_tests = np.empty((0, len(stat_names_bat)))
	fld_tests = np.empty((0, len(stat_names_fld)))

	ids_pit = []
	ids_bat = []
	ids_fld = []

	ids_pit_tests = []
	ids_bat_tests = []
	ids_fld_tests = []

	print("Filling out statistic arrays (", len(player_ids), " ids)...")
	for pidx in range(len(player_ids)):
		pid = player_ids[pidx]
		print(pidx)
		temp = data_api.get_player_pitching(pid)
		if (random.random() < 0.95):
			# Add to the train set
			if temp is not None:
				pit = temp.to_numpy()[:, 5:]
				pit_stats = np.append(pit_stats, pit, axis=0)
				ids_pit += [pid] * pit.shape[0]
			# Collate batting data
			bat = data_api.get_player_batting(pid).to_numpy()[:, 5:]
			bat_stats = np.append(bat_stats, bat, axis=0)
			ids_bat += [pid] * bat.shape[0]
			# Collate fielding data
			fld = data_api.get_player_fielding(pid).to_numpy()[:, 6:]
			fld_stats = np.append(fld_stats, fld, axis=0)
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
	print("Importing player data ...")
	data_api = BaseballData()
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

if __name__ == '__main__':
	main()
