// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {SupplyChain} from "./SupplyChain.sol";
import {Test} from "forge-std/Test.sol";

contract RecipientContract {}

contract SupplyChainTest is Test {
	SupplyChain supplyChain;
	RecipientContract recipient;

	function setUp() public {
		supplyChain = new SupplyChain();
		recipient = new RecipientContract();
	}

	function test_Pay() public {
		supplyChain.pay{value: 50}(0, 0, 0, 0, SupplyChain.ItemMetadata({ id: 0x26a1c5091377aa3c, name: "Carrots" }), 1000, payable(address(recipient)));
	}

	function testFuzz_Pay(int32 sourceLatitude,
						  int32 sourceLongitude,
						  int32 destinationLatitude,
						  int32 destinationLongitude,
						  SupplyChain.ItemMetadata calldata item,
						  uint256 completionTime,
						  address payable destination) public {
		bool failing = false;
		unchecked {
			if (completionTime + block.timestamp < completionTime) {
				failing = true;
			}
		}

		if (failing) {
			vm.expectRevert();
		}

		uint256 previousBalance = address(supplyChain).balance;
		supplyChain.pay{value: 100}(sourceLatitude, sourceLongitude, destinationLatitude, destinationLongitude, item, completionTime, destination);
		uint256 newBalance = address(supplyChain).balance;
		if (!failing) {
			assertEq(newBalance, 100 + previousBalance);
		} else {
			assertEq(newBalance, previousBalance);
		}
	}

	function test_FuzzAcknowledgeFailing(uint256 id) public {
		vm.expectRevert();
		supplyChain.acknowledge(id);
	}
}
