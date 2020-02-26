from pca import PCA
from api import BaseballData
import numpy as np
import sys
import random

random.seed(57)

def get_pca():
	print("Importing player data ...")
	data_api = BaseballData()
	player_ids = data_api.players().tolist()
	print("Done.")

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

	print("Filling out statistic arrays (", len(player_ids), " ids)...")
	for pidx in range(len(player_ids)):
		pid = player_ids[pidx]
		print(pidx)
		temp = data_api.get_player_pitching(pid)
		if random.choices((True, False), weights=(0.95, 0.05)):
			# Add to the train set
			if temp is not None:
				pit = temp.to_numpy()[:, 5:]
				pit_stats = np.append(pit_stats, pit, axis=0)
			# Collate batting data
			bat = data_api.get_player_batting(pid).to_numpy()[:, 5:]
			bat_stats = np.append(bat_stats, bat, axis=0)
			# Collate fielding data
			fld = data_api.get_player_fielding(pid).to_numpy()[:, 6:]
			fld_stats = np.append(fld_stats, fld, axis=0)
			sys.stdout.write("\033[F")
		else:
			# Add to the test set
			if temp is not None:
				pit = temp.to_numpy()[:, 5:]
				pit_tests = np.append(pit_tests, pit, axis=0)
			# Collate batting data
			bat = data_api.get_player_batting(pid).to_numpy()[:, 5:]
			bat_tests = np.append(bat_tests, bat, axis=0)
			# Collate fielding data
			fld = data_api.get_player_fielding(pid).to_numpy()[:, 6:]
			fld_tests = np.append(fld_tests, fld, axis=0)
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

	print("Nans? ", np.any(np.isnan(pit_stats)))
	print("Infs? ", np.any(np.isinf(pit_stats)))

	print("Done.")

	# the pca objects take column vectors:
	print("Running PCA ...")
	#pit_anls = PCA(np.transpose(pitcher_stats), labels=(stat_names_pit + stat_names_bat + stat_names_fld))
	#nop_anls = PCA(np.transpose(nopitch_stats), labels=(stat_names_bat + stat_names_fld))
	print(pit_stats)
	pit_anls = PCA(np.transpose(pit_stats), labels=stat_names_pit)
	bat_anls = PCA(np.transpose(bat_stats), labels=stat_names_bat)
	fld_anls = PCA(np.transpose(fld_stats), labels=stat_names_fld)

	pit_anls.find_eigens()
	bat_anls.find_eigens()
	fld_anls.find_eigens()
	print("Done.")

	return (pit_anls, bat_anls, fld_anls, pit_tests, bat_tests, fld_tests)

def main():
	pa, ba, fa, pt, bt, ft = get_pca()

	pa.print_eigens()

if __name__ == '__main__':
	main()
