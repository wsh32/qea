from pca import PCA
from api import BaseballData
import numpy as np
import sys

def main():
	print("Importing player data ...")
	data_api = BaseballData()
	player_ids = data_api.players().tolist()
	print("Done.")

	# get the column names for the three categories of statistics
	stat_names_pit = data_api.get_player_pitching('salech01').columns[5:].tolist() # hardcoded :(
	stat_names_bat = data_api.get_player_batting(player_ids[0]).columns[5:].tolist()
	stat_names_fld = data_api.get_player_fielding(player_ids[0]).columns[5:].tolist()

	# build seperate arrays for pitchers and non-pitchers.
	pitcher_stats = np.array([[]])
	nopitch_stats = np.array([[]])

	print("Filling out statistic arrays (", len(player_ids), " ids)...")
	for pidx in range(len(player_ids)):
		pid = player_ids[pidx]
		print(pidx)
		temp = data_api.get_player_pitching(pid)
		if temp is not None:
			pit = temp.to_numpy()[:, 5:]
		bat = data_api.get_player_batting(pid).to_numpy()[:, 5:]
		fld = data_api.get_player_fielding(pid).to_numpy()[:, 5:]
		if data_api.is_pitcher(pid):
			# The first time a value is added the array is of the wrong shape for appending
			if pitcher_stats.shape[1] == 0:
				#pitcher_stats = np.array(np.block([pit, bat, fld]))
				pitcher_stats = np.array(np.block([pit]))
			else:
				#pitcher_stats = np.append(pitcher_stats, np.block([pit, bat, fld]), axis=0)
				pitcher_stats = np.append(pitcher_stats, np.block([pit]), axis=0)
		else:
			# Same for this array
			if nopitch_stats.shape[1] == 0:
				#nopitch_stats = np.array(np.block([bat, fld]))
				nopitch_stats = np.array(np.block([bat]))
			else:
				#nopitch_stats = np.append(nopitch_stats, np.block([bat, fld]), axis=0)
				nopitch_stats = np.append(nopitch_stats, np.block([bat]), axis=0)
		sys.stdout.write("\033[F")
	print("Done.")

	print("Cleaning data ...")
	# Replace nans in the dataset with the column mean

	pitcher_means = np.nanmean(pitcher_stats.astype(np.float64), axis=0)
	nopitch_means = np.nanmean(nopitch_stats.astype(np.float64), axis=0)

	pitcher_means = np.where(np.isnan(pitcher_means), np.ma.array(pitcher_means, 
		mask = np.isnan(pitcher_means)).mean(axis = 0), pitcher_means) 
	nopitch_means = np.where(np.isnan(nopitch_means), np.ma.array(nopitch_means, 
		mask = np.isnan(nopitch_means)).mean(axis = 0), nopitch_means)    

	print("Nans? ", np.any(np.isnan(pitcher_means)))

	#idx = np.where(np.isnan(pitcher_means))
	#pitcher_stats[idx] = np.take(pitcher_means, idx[0])

	#idx = np.where(np.isnan(nopitch_means))
	#nopitch_stats[idx] = np.take(nopitch_means, idx[0])

	print("Done.")

	# the pca objects take column vectors:
	print("Running PCA ...")
	#pit_anls = PCA(np.transpose(pitcher_stats), labels=(stat_names_pit + stat_names_bat + stat_names_fld))
	#nop_anls = PCA(np.transpose(nopitch_stats), labels=(stat_names_bat + stat_names_fld))
	pit_anls = PCA(np.transpose(pitcher_stats), labels=(stat_names_pit + stat_names_bat))
	nop_anls = PCA(np.transpose(nopitch_stats), labels=(stat_names_bat))

	pit_anls.find_eigens()
	nop_anls.find_eigens()
	print("Done.")

	print("Pitcher principle components:")
	pit_anls.print_eigens()

	print("Non-pitcher principle components:")
	nop_anls.print_eigens()

if __name__ == '__main__':
	main()
