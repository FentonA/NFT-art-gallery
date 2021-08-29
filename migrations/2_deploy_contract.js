var SquareVierifier = artifacts.require("Verfier");
var SolnSquareVerifier = artifacts.require("./SolnSquareVerifier.sol");

module.exports = function(deployer){
    deployer.deploy(SquareVierifier).then(()=>{
        return deployer.deploy(SolnSquareVerifier, SquareVerifier.address)
    });
}
