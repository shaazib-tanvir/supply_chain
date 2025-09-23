// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

error ZeroTransaction();
error PendingTransaction();
error AlreadyCompleted();
error NoTransactionFound();
error NotExpired(uint256 expirationTimestamp, uint256 currentTimestamp);
error NoReputationPoints();

contract SupplyChain {
	struct User {
		int64 reputation;
		mapping(address => bool) delegatedRp;
	}

	struct ItemMetadata {
		uint256 id;
		string name;
	}

	struct Point {
		address payable addr;
		int32 latitude; // represents latitude * 10^6
		int32 longitude; // represents longitude * 10^6
	}

	struct Txn {
		Point source;
		Point destination;
		ItemMetadata item;
		uint256 amount;
		uint256 expirationTimestamp;
		bool completed;
	}

	mapping(address => User) public users;
	mapping(uint256 => Txn[]) public txns;

	function pay(int32 sourceLatitude,
				 int32 sourceLongitude,
				 int32 destinationLatitude,
				 int32 destinationLongitude,
				 ItemMetadata calldata item,
				 uint256 completionTime,
				 address payable destination) external payable {
		require(msg.value > 0, ZeroTransaction());
		require(txns[item.id].length == 0 || txns[item.id][txns[item.id].length - 1].completed, PendingTransaction());

		Txn memory txn = Txn({
			source: Point({
				latitude: sourceLatitude,
				longitude: sourceLongitude,
				addr: payable(msg.sender)
			}),
			destination: Point({
				latitude: destinationLatitude,
				longitude: destinationLongitude,
				addr: destination
			}),
			item: item,
			amount: msg.value,
			expirationTimestamp: block.timestamp + completionTime,
			completed: false
		});
		txns[item.id].push(txn);
	}

	function acknowledge(uint256 itemId) external {
		require(txns[itemId].length > 0, NoTransactionFound());
		Txn memory txn = txns[itemId][txns[itemId].length - 1];
		require(!txn.completed, AlreadyCompleted());

		txns[itemId][txns[itemId].length - 1].completed = true;
		users[msg.sender].reputation += 1;
		users[txns[itemId][txns[itemId].length - 1].destination.addr].reputation += 1;
		payable(txns[itemId][txns[itemId].length - 1].destination.addr).transfer(txn.amount);
	}

	function cancel(uint256 itemId) external {
		require(txns[itemId].length > 0, NoTransactionFound());
		Txn memory txn = txns[itemId][txns[itemId].length - 1];

		require(!txn.completed, AlreadyCompleted());
		require(txn.expirationTimestamp <= block.timestamp, NotExpired(txn.expirationTimestamp, block.timestamp));

		address destinationAddress = txns[itemId][txns[itemId].length - 1].destination.addr;
		users[msg.sender].delegatedRp[destinationAddress] = true;
		users[destinationAddress].delegatedRp[msg.sender] = true;
		txns[itemId].pop();
	}

	function vote(address person, bool positive) external {
		require(users[msg.sender].delegatedRp[person], NoReputationPoints());
		if (positive) {
			users[person].reputation += 1;
		} else {
			users[person].reputation -= 1;
		}
	}
}
