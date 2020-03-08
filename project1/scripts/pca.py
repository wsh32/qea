import numpy as np
from scipy import stats

class PCA():
	def __init__(self, vectors, labels=None):
		# Vectors is a numpy 2D array of column vectors on which to apply PCA
		try:
			assert len(vectors.shape) == 2
		except AttributeError:
			raise AttributeError("vectors must be a 2D numpy array")
		self.vectors = np.array(vectors, dtype=np.float64)
		self.labels = labels # Optional labels for each dimension
		self.ndim = vectors.shape[0] # Number of dimensions in the data
		self.means = None # Means (by dimension)
		self.c_means = None # Means (by dimension in eigenspace)
		self.R = None # Covariance matrix
		self.V = None # Eigenvectors
		self.D = None # Eigenvalues (flat vector)
		self.Sigma = None # Standard deviations (square root of the eigenvalues)
	def find_covariance(self):
		# Finds the covariance matrix of the supplied vectors
		print("Finding covariance matrix ...")
		self.means = np.mean(self.vectors, axis=1)
		horiz = self.vectors.transpose() # Transpose to row vectors
		horiz -= self.means

		self.R = np.matmul(horiz.transpose(), horiz)
		self.R /= np.sqrt(self.vectors.shape[1] - 1)
		assert self.R.shape == (self.ndim, self.ndim)
		print("Done.")
	def find_eigens(self):
		print("Finding eigenvectors ...")
		if np.all(self.R == None):
			self.find_covariance()
		# Finds the eigenvectors of the covariance matrix
		self.D, self.V = np.linalg.eig(self.R)
		# These values are not necessarily sorted. Sort them:
		idx = self.D.argsort()[::-1]
		self.D = self.D[idx]
		self.V = self.V[:,idx]
		self.Sigma = np.sqrt(self.D)
		print("Done.")
	def print_eigen(self, idx):
		# Prints a prettified version of the idxth eigenvector and its value
		if idx >= self.ndim:
			raise ValueError("index out of bounds")
		print("Eigenvector number ", idx, ", Eigenvalue ", self.D[idx], " (sigma ", self.Sigma[idx], " )")
		for i in range(self.ndim):
			print((self.labels[i].rjust(15, ' ') if self.labels else str(i).rjust(15, ' ')), " :: ", self.V[i, idx])
		print("---")
	def print_eigens(self, num=None):
		# Prints the top num eigenvectors and their values
		if not num:
			num = self.ndim
		if num > self.ndim:
			raise ValueError("too many eigenvectors requested")
		if np.all(self.V == None):
			self.find_eigens()
		for i in range(num):
			self.print_eigen(i)

def main():
	vecs = np.array([[4, 6, 2, 6], [3, 3, 2, 8], [7, 4, 5, 3]])
	print(vecs.shape)
	test = PCA(vecs, labels=['ABC', 'DEF', 'GHI'])

	test.find_eigens()

	test.print_eigens(test.ndim)

if __name__ == '__main__':
	main()