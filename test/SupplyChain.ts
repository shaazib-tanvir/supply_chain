import assert from "node:assert/strict"
import { describe, it } from "node:test"

import { network } from "hardhat"
import { parseEther } from "viem"
import { parseAccount } from "viem/utils"

describe("Supply Chain", async function() {
	const { viem } = await network.connect()
	const testClient = await viem.getTestClient()
	const publicClient = await viem.getPublicClient()

	it("Pay", async () => {
		await testClient.impersonateAccount({
			address: "0xe4470ddcfad1027d088a5b59973eee355d292715"
		})
		await testClient.impersonateAccount({
			address: "0xeeea83374b145ce7d04c2d129dedfea30142112b"
		})
		testClient.setBalance({
			address: "0xeeea83374b145ce7d04c2d129dedfea30142112b",
			value: parseEther("1000"),
		})

		const supplyChain = await viem.deployContract("SupplyChain")
		await supplyChain.write.pay([0, 0, 0, 0, {id: BigInt("0xcac345be0db07c818fbfc63adc1db0576e166fdc05a026bda3d248287bd599b3"), name: "Carrots"}, BigInt(1000), "0xe4470ddcfad1027d088a5b59973eee355d292715"], {
			account: parseAccount("0xeeea83374b145ce7d04c2d129dedfea30142112b"),
			value: parseEther("10"),
		})
	})

	it("Pay And Acknowledge", async function() {
		const source = "0xeeea83374b145ce7d04c2d129dedfea30142112b"
		const destination = "0xe4470ddcfad1027d088a5b59973eee355d292715"
		await testClient.impersonateAccount({
			address: source
		})
		await testClient.impersonateAccount({
			address: destination
		})
		testClient.setBalance({
			address: source,
			value: parseEther("1000"),
		})
		testClient.setBalance({
			address: destination,
			value: parseEther("0"),
		})

		const supplyChain = await viem.deployContract("SupplyChain")
		const id = BigInt("0x1d8e5d47af61bf3136e9fb2b8e3756e4238b1b44732431c45b9c6f4a77f762f6")
		await supplyChain.write.pay([0, 0, 0, 0, {id: id, name: "Banana"}, BigInt(1000), destination], {
			account: parseAccount(source),
			value: parseEther("10"),
		})
		await supplyChain.write.acknowledge([id], {
			account: parseAccount(source),
		})
		const newBalance = await publicClient.getBalance({
			address: destination
		})
		assert.equal(newBalance, parseEther("10"))
	})
})
