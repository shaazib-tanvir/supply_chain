// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract SupplyChain {
	struct User {
		int16 reputation;
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
				 address payable destination) payable external {
		require(msg.value > 0);
		require(txns[item.id].length == 0 || txns[item.id][txns[item.id].length - 1].completed);

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
		require(txns[itemId].length > 0);
		Txn memory txn = txns[itemId][txns[itemId].length - 1];
		require(!txn.completed);

		payable(msg.sender).transfer(txn.amount);
		txns[itemId][txns[itemId].length - 1].completed = true;
	}

	function cancel(uint256 itemId) external {
		require(txns[itemId].length > 0);
		Txn memory txn = txns[itemId][txns[itemId].length - 1];

		require(!txn.completed);
		require(txn.expirationTimestamp > block.timestamp);

		txns[itemId].pop();
	}
}
