D <- numeric(5)
for (q in 1:20) {
#### initialize ####
#  set S
S <- 1: 100

# fix positive real numbers c in [0, 2]
ct = 0
c <- numeric(10000)
for (i in 1:100) {
  for (j in 1:100) {
    ct = ct + 1
    c[ct] = runif(1, min=0, max=2)
  }
}

# set tolerance
tau <- 10^(-6)

# fix initial data (assume t fall in 1:100, x, y fall in [0,5])
ct = 0
x <- numeric(10000)
for (t in 1:100) {
  for (j in 1:100) {
    ct = ct + 1 #ct = (t - 1) * 100 + i
    x[ct] <- runif(1, min=0, max=5)
  }
}

ct = 0
y <- numeric(10000)
for (t in 1:100) {
  for (j in 1:100) {
    ct = ct + 1
    y[ct] <- runif(1, min=0, max=5)
  }
}

# set M, v_max, v_min
M <- 10^6
v_max <- rep(-M, 100)
v_min <- rep(M, 100)

# set K
K <- 10^3

#### S0 ####
# randomly draw v_tilde
v_tilde <- numeric(100)
for (i in 1:100) {
  v_tilde[i] = runif(1, min=0, max = 2)
}

# set K = 
K <- K - 1

#### S1 ####
# define x_tilde
x_tilde <- numeric(10000)
ct = 0
exp_sum = 0
for (t in 1:100) {
  for (i in 1:100) {
    for (l in 1: 100) {
      exp_sum = exp_sum + exp(v_tilde[l] + c[100*(i - 1) + l])
     }
    ct = ct + 1
    x_tilde[ct] = x[ct]/exp_sum
  }
}

# find gamma that minimize the expression
gamma <- numeric(100)
ct = 0
ct2 = 0
ct3 = 0
ysum = 0
for (j in 1:100) {
  exp1 = 0
  ysum = 0
  for (t in 1: 100) {
    for (i in 1: 100) {
      ct = (i - 1) * 100 + j
      ct2 = (t - 1) * 100 + i
      exp1 = exp1 + exp(c[ct]*x_tilde[ct2])
    }
    ct3 = (t - 1) * 100 + j
    ysum = ysum + y[ct3]
  }
  gamma[j] = ysum/exp1
}

# define V
v <- numeric(100)
for (i in 1:100) {
  v[i] = log(x = gamma[i])
}

#### S2 ####
# check the difference between v and v_tilde
step3 <- 0
for (i in 1:100) {
  if (abs(v_tilde[i] - v[i]) < tau) {
    step3 = step3 + 1
  }
}

# proceed to step 3 if condition satisfied;
# otherwise reset valeus of v_tilde 
three <- FALSE
if (step3 == 100) {
  three <- TRUE
} else {
  for (i in 1:100) {
    v_tilde[i] = v[i]
  }
}

# second part
# if three is false, redo step 1&2
while (!three) {
  
  #### S1 ####
  # define x_tilde
  x_tilde <- numeric(10000)
  ct = 0
  exp_sum = 0
  for (t in 1:100) {
    for (i in 1:100) {
      for (l in 1: 100) {
        exp_sum = exp_sum + exp(v_tilde[l] + c[100*(i - 1) + l])
      }
      ct = ct + 1
      x_tilde[ct] = x[ct]/exp_sum
    }
  }
  
  # find gamma that minimize the expression
  gamma <- numeric(100)
  ct = 0
  ct2 = 0
  ct3 = 0
  ysum = 0
  for (j in 1:100) {
    exp1 = 0
    ysum = 0
    for (t in 1: 100) {
      for (i in 1: 100) {
        ct = (i - 1) * 100 + j
        ct2 = (t - 1) * 100 + i
        exp1 = exp1 + exp(c[ct]*x_tilde[ct2])
      }
      ct3 = (t - 1) * 100 + j
      ysum = ysum + y[ct3]
    }
    gamma[j] = ysum/exp1
  }
  
  # define V
  v <- numeric(100)
  for (i in 1:100) {
    v[i] = log(x = gamma[i])
  }
  
  #### S2 ####
  # check the difference between v and v_tilde
  step3 <- 0
  for (i in 1:100) {
    if (abs(v_tilde[i] - v[i]) < tau) {
      step3 = step3 + 1
    }
  }
  
  # proceed to step 3 if condition satisfied;
  # otherwise reset valeus of v_tilde 
  three <- FALSE
  if (step3 == 100) {
    three <- TRUE
  } else {
    for (i in 1:100) {
      v_tilde[i] = v[i]
    }
  }
  
}

#### S3 ####
for (i in 1:100) {
  v_max[i] = max(v_max[i], v[i])
  v_min[i] = min(v_min[i], v[i])
}

# start from S0 if K > 0
while (K > 0) {
  #### S0 ####
  # randomly draw v_tilde
  v_tilde <- numeric(100)
  for (i in 1:100) {
    v_tilde[i] = runif(1, min=0, max = 2)
  }
  
  # set K = 
  K <- K - 1
  
  #### S1 ####
  # define x_tilde
  x_tilde <- numeric(10000)
  ct = 0
  exp_sum = 0
  for (t in 1:100) {
    for (i in 1:100) {
      for (l in 1: 100) {
        exp_sum = exp_sum + exp(v_tilde[l] + c[100*(i - 1) + l])
      }
      ct = ct + 1
      x_tilde[ct] = x[ct]/exp_sum
    }
  }
  
  # find gamma that minimize the expression
  gamma <- numeric(100)
  ct = 0
  ct2 = 0
  ct3 = 0
  ysum = 0
  for (j in 1:100) {
    exp1 = 0
    ysum = 0
    for (t in 1: 100) {
      for (i in 1: 100) {
        ct = (i - 1) * 100 + j
        ct2 = (t - 1) * 100 + i
        exp1 = exp1 + exp(c[ct]*x_tilde[ct2])
      }
      ct3 = (t - 1) * 100 + j
      ysum = ysum + y[ct3]
    }
    gamma[j] = ysum/exp1
  }
  
  # define V
  v <- numeric(100)
  for (i in 1:100) {
    v[i] = log(x = gamma[i])
  }
  
  #### S2 ####
  # check the difference between v and v_tilde
  step3 <- 0
  for (i in 1:100) {
    if (abs(v_tilde[i] - v[i]) < tau) {
      step3 = step3 + 1
    }
  }
  
  # proceed to step 3 if condition satisfied;
  # otherwise reset valeus of v_tilde 
  three <- FALSE
  if (step3 == 100) {
    three <- TRUE
  } else {
    for (i in 1:100) {
      v_tilde[i] = v[i]
    }
  }
  
  # if three is false, redo step 1&2
  while (!three) {
    
    #### S1 ####
    # define x_tilde
    x_tilde <- numeric(10000)
    ct = 0
    exp_sum = 0
    for (t in 1:100) {
      for (i in 1:100) {
        for (l in 1: 100) {
          exp_sum = exp_sum + exp(v_tilde[l] + c[100*(i - 1) + l])
        }
        ct = ct + 1
        x_tilde[ct] = x[ct]/exp_sum
      }
    }
    
    # find gamma that minimize the expression
    gamma <- numeric(100)
    ct = 0
    ct2 = 0
    ct3 = 0
    ysum = 0
    for (j in 1:100) {
      exp1 = 0
      ysum = 0
      for (t in 1: 100) {
        for (i in 1: 100) {
          ct = (i - 1) * 100 + j
          ct2 = (t - 1) * 100 + i
          exp1 = exp1 + exp(c[ct]*x_tilde[ct2])
        }
        ct3 = (t - 1) * 100 + j
        ysum = ysum + y[ct3]
      }
      gamma[j] = ysum/exp1
    }
    
    # define V
    v <- numeric(100)
    for (i in 1:100) {
      v[i] = log(x = gamma[i])
    }
    
    #### S2 ####
    # check the difference between v and v_tilde
    step3 <- 0
    for (i in 1:100) {
      if (abs(v_tilde[i] - v[i]) < tau) {
        step3 = step3 + 1
      }
    }
    
    # proceed to step 3 if condition satisfied;
    # otherwise reset valeus of v_tilde 
    three <- FALSE
    if (step3 == 100) {
      three <- TRUE
    } else {
      for (i in 1:100) {
        v_tilde[i] = v[i]
      }
    }
    
  }
  
  #### S3 ####
  for (i in 1:100) {
    v_max[i] = max(v_max[i], v[i])
    v_min[i] = min(v_min[i], v[i])
  }
  
}

#### S4 ####
D[q] <- max(abs(v_max - v_min))
}

write.table(D, "/home/jsun50/GitHub/BFI_Data_Task/copy_d_results.txt", sep="\t")
max_D = max(D)
write.table(max_D, "/home/jsun50/GitHub/BFI_Data_Task/max_d.txt", sep="\t")
