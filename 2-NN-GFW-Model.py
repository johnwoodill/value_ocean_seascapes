
import pandas
from keras.models import Sequential
from keras.layers import Dense
from keras.wrappers.scikit_learn import KerasRegressor
from sklearn.model_selection import cross_val_score
from sklearn.model_selection import KFold
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
from keras.callbacks import EarlyStopping
from keras import callbacks
from sklearn import preprocessing
from sklearn.metrics import accuracy_score, r2_score, mean_squared_error

# Set early stop
es = EarlyStopping(monitor='val_loss', patience=3, verbose=0,
    restore_best_weights=True)

def adapt_learning_rate(epoch):
    return 0.001 * epoch

# Set adaptive learning rate
my_lr_scheduler = callbacks.LearningRateScheduler(adapt_learning_rate)

gfw = pd.read_csv("data/processed/1-gfw_grids_sst_chl_sea.csv")

months = pd.get_dummies(gfw['month'])
years = pd.get_dummies(gfw['year'])
seas = pd.get_dummies(gfw['sea'])


moddat = pd.concat([gfw, months, years, seas], axis=1)

X_train = moddat[moddat['year'] != 2018]
y_train = X_train['fishing_hours']
X_train = X_train.drop(columns=['grid', 'lat', 'lon', 'month', 'year', 'sea', 'fishing_hours', 'lat_lon'])

X_test = moddat[moddat['year'] == 2018]
y_test = X_test['fishing_hours']
X_test = X_test.drop(columns=['grid', 'lat', 'lon', 'month', 'year', 'sea', 'fishing_hours', 'lat_lon'])

scaler = preprocessing.StandardScaler().fit(X_train.values)
X_train_scaled = scaler.transform(X_train.values)
X_test_scaled = scaler.transform(X_test.values)

def mod_reg(X_train, y_train):
        
    mod = Sequential()
    # mod.add(Dense(60, activation='relu'))
    mod.add(Dense(30, activation='relu'))
    mod.add(Dense(15, activation='relu'))
    mod.add(Dense(10, activation='relu'))
    mod.add(Dense(5, activation='relu'))
    mod.add(Dense(1, activation='relu'))
    mod.compile(optimizer='Adam', loss='mean_squared_error')
    mod.fit(X_train, y_train.values, validation_split=0.2,
        shuffle=True, epochs=1000,  batch_size=128,
        callbacks=[es, my_lr_scheduler])
    return mod

ksmod = mod_reg(X_train_scaled, y_train)

### Predict train/test set
y_pred_train = ksmod.predict(X_train_scaled)    
y_pred_test = ksmod.predict(X_test_scaled)   
    
### Get regression metrics
train_r2 = r2_score(y_train, y_pred_train)
test_r2 = r2_score(y_test, y_pred_test)

print(train_r2)
print(test_r2)

train_rmse = mean_squared_error(y_train, y_pred_train)
test_rmse = mean_squared_error(y_test, y_pred_test)