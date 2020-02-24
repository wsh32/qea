from pca import PCA
from api import BaseballData
import numpy as np

def main():
	print("Importing player data ...")
	data_api = BaseballData()
	player_ids = data_api.players()
	print("Done.")

	# get the column names for the three categories of statistics
	stat_names_pit = data_api.get_player_pitching(player_ids[0]).columns
	stat_names_bat = data_api.get_player_batting(player_ids[0]).columns
	stat_names_fld = data_api.get_player_fielding(player_ids[0]).columns

	# build seperate arrays for pitchers and non-pitchers.
	pitcher_stats = np.array([[]])
	nopitch_stats = np.array([[]])

	print("Filling out statistic arrays ...")
	for pid in player_ids:
		pit = data_api.get_player_pitching(pid).to_numpy()
		bat = data_api.get_player_batting(pid).to_numpy()
		fld = data_api.get_player_fielding(pid).to_numpy()
		if data_api.is_pitcher(pid):
			# The first time a value is added the array is of the wrong shape for appending
			if pitcher_stats.shape[1] == 0:
				pitcher_stats = np.array(np.block([pit, bat, fld]))
			else:
				pitcher_stats = np.append(pitcher_stats, np.block([pit, bat, fld]), axis=0)
		else:
			# Same for this array
			if nopitch_stats.shape[1] == 0:
				nopitch_stats = np.array(np.block([pit, bat, fld]))
			else:
				nopitch_stats = np.append(nopitch_stats, np.block([bat, fld]), axis=0)
	print("Done.")

	print("Cleaning data ...")
	# Replace nans in the dataset with the column mean

	pitcher_means = np.nanmean(pitcher_stats, axis=0)
	nopitch_means = np.nanmean(nopitch_stats, axis=0)

	idx = np.where(np.isnan(pitcher_means))
	pitcher_stats[idx] = np.take(pitcher_means, idx[1])

	idx = np.where(np.isnan(nopitch_means))
	nopitch_stats[idx] = np.take(nopitch_means, idx[1])

	print("Done.")

	# the pca objects take column vectors:
	print("Running PCA ...")
	pit_anls = PCA(np.transpose(pitcher_stats), labels=(stat_names_pit + stat_names_bat + stat_names_fld))
	nop_anls = PCA(np.transpose(nopitch_stats), labels=(stat_names_bat + stat_names_fld))

	pit_anls.find_eigens()
	nop_anls.find_eigens()
	print("Done.")

	print("Pitcher principle components:")
	pit_anls.print_eigens()

	print("Non-pitcher principle components:")
	nop_anls.print_eigens()

