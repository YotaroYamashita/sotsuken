using Random
using Distributions
using DelimitedFiles
using Plots

const simulations = 100#シミュレーションの回数
const time_steps = 30
const a = 0.2 #過去の影響が現在に及ぼす度合い
const B = -1.0 #過去の市場リターンr(t-1)が現在に与える影響度合い
const l = 40.0 #流動性を表すパラメータ
const N = 2500 #エージェント数
const CV = 0.1

function simulate_agents()
    K_expect_values = Float64[]
    r_expect_values = Float64[]
    b_max_values = Float64[]
    sigma_max = 0.03
    sigma = rand(Uniform(0, sigma_max), N)

    for m in 0:1000
        r_expect = 0.0
        K_expect = 0.0
        b_max = 0.01 + 0.01 * m 
        b = rand(Uniform(0, b_max), N)
        push!(b_max_values, b_max)

        for _ in 1:simulations   
            s = zeros(N)
            K = zeros(N)           
            r = 0.0
            G_pre = randn() #t-1での外部の影響
            for t in 1:time_steps
                G = randn()
                epsilon = rand(Normal(0, CV + rand(Uniform(0, 0.1))), N)
                K = b .+ a .* K .+ B .* r .* G_pre
                G_pre = G#G_preの更新
                s = sign.(K .* sum.(s) .+ sigma .* G .+ epsilon .- K .* s)
                r = sum(s) / (l * N)
            end

            r_expect += r / simulations
            K_expect += sum(K) / N   
        end
        K_expect = K_expect / simulations          

        push!(K_expect_values, K_expect)
        push!(r_expect_values, r_expect)
    end

    return b_max_values, K_expect_values
end

b_max_values, K_expect_values = simulate_agents()
