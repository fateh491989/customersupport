const functions = require('firebase-functions')
const admin = require('firebase-admin')
admin.initializeApp()

exports.sendNotification = functions.firestore
  .document('messages/{groupId1}/{groupId2}/{message}')
  .onCreate((snap, context) => {
    console.log('----------------start function--------------------')
    // Writing this function for customer recieve
    const doc = snap.data()
    console.log(doc)
    const idFrom = doc.idFrom
    const idTo = doc.idTo
    const contentMessage = doc.content
    console.log(idTo)
    console.log(idFrom)
    // Get push token user to (receiver)
    admin
      .firestore()
      .collection('admin')
      .where('uid', '==', idTo)
      .get()
      .then(querySnapshot => {
        querySnapshot.forEach(userTo => {
          console.log('Hello i am idTo')
          //console.log(`Found user to: ${userTo.data().nickname}`)
          console.log(`Found user to: ${userTo.data().chattingWith}`)
          //console.log(`Found user to: ${userTo.data().pushToken}`)
          //console.log(userTo.data().pushToken && userTo.data().chattingWith !== idFrom)

          if (userTo.data().chattingWith != idFrom) {
            // Get info user from (sender)
            console.log(`Sender query right`)
            admin
              .firestore()
              .collection('allUsers')
              .where('uid', '==', idFrom)
              .get()
              .then(querySnapshot2 => {
                querySnapshot2.forEach(userFrom => {
                  console.log(`Found user from: ${userFrom.data().name}`)
                  const payload = {
                    notification: {
                      title: `You have a message from "${userFrom.data().name}"`,
                      body: contentMessage,
                      badge: '1',
                      sound: 'default'
                    }
                  }
                  // Let push to the target device
                  admin
                    .messaging()
                    .sendToDevice(userTo.data().userToken, payload)
                    .then(response => {
                      console.log('Successfully sent message:', response)
                    })
                    .catch(error => {
                      console.log('Error sending message:', error)
                    })
                })
              })
          } else {
            console.log('Can not find pushToken target user')
          }
        })
      })


    admin
          .firestore()
          .collection('allUsers')
          .where('uid', '==', idTo)
          .get()
          .then(querySnapshot => {
            querySnapshot.forEach(userTo => {
              console.log('Hello i am idTo')
              //console.log(`Found user to: ${userTo.data().nickname}`)
              console.log(`Found user to: ${userTo.data().chattingWith}`)
              //console.log(`Found user to: ${userTo.data().pushToken}`)
              //console.log(userTo.data().pushToken && userTo.data().chattingWith !== idFrom)

              if (userTo.data().chattingWith != idFrom) {
                // Get info user from (sender)
                admin
                  .firestore()
                  .collection('admin')
                  .where('uid', '==', idFrom)
                  .get()
                  .then(querySnapshot2 => {
                    querySnapshot2.forEach(userFrom => {
                      console.log(`Found user from: ${userFrom.data().name}`)
                      const payload = {
                        notification: {
                          title: `You have a message from "${userFrom.data().name}"`,
                          body: contentMessage,
                          badge: '1',
                          sound: 'default'
                        }
                      }
                      // Let push to the target device
                      admin
                        .messaging()
                        .sendToDevice(userTo.data().userToken, payload)
                        .then(response => {
                          console.log('Successfully sent message:', response)
                        })
                        .catch(error => {
                          console.log('Error sending message:', error)
                        })
                    })
                  })
              } else {
                console.log('Can not find pushToken target user')
              }
            })
          })
    return null
  })
