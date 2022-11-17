const { network, ethers } = require("hardhat")
const { developmentChains } = require("../helper-hardhat-config")

//https://docs.chain.link/vrf/v2/subscription/supported-networks
const BASE_FEE = ethers.utils.parseEther("0.25")    //Premium
const GAS_PRICE_LINK = 1e9 //1000000000 //link per gas. Calculated value based on the gas price of the chain 

module.exports = async function({ getNamedAccounts, deployments }){
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const args = [BASE_FEE, GAS_PRICE_LINK]

    if(developmentChains.includes(network.name)){
        log("Local network detected! Deploying mocks...")
        // deploy a mock vrfCoordinator
        await deploy("VRFCoordinatorV2Mock",{
            from: deployer,
            args: args,
            log: true
        })
        log("Mock deployed!")
        log("----------------------------------------------------------------------")
    }
}

module.exports.tags = ["all", "mocks"]