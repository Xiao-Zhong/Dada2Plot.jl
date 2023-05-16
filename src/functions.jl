##read dada2 output files, sample table
function input2df(asv_file, taxa_file, sample_file)
    asv = CSV.File(asv_file) |> DataFrame;
    taxa = CSV.File(taxa_file) |> DataFrame;
    taxa = permutedims(taxa, 1)
    sample = CSV.File(sample_file) |> DataFrame
    sample.Treatment = strip.(sample.Treatment)
    return asv, taxa, sample
end

##merge these tables above to be a metadata table
function df_merger(asv, taxa, sample)
    asv_taxa = vcat(asv, taxa)
    new_asv_id = ["ASV-$(i-1)" for i in 2:ncol(asv_taxa)]
    rename!(asv_taxa, names(asv_taxa)[2:end] .=> new_asv_id)
    leftjoin!(asv_taxa, sample, on = "Column1" => "Sample Name")
    #remove taxa rows or the rows with "missing" in the last few columns
    df_taxa = filter(:Treatment => ismissing, asv_taxa)
    filter!(:Treatment => !ismissing, asv_taxa)
    return asv_taxa, df_taxa
end

##filter out ASV with few read support and existing in few samples
function asv_filter(asv, treatment, reads_cutoff, samples_cutoff)
    filter!(:Treatment => x -> x ∈ treatment, asv)
    #CSV.write("asv.csv", asv)
    group_label = length(treatment) > 1 ? "Treatment" : "Column1"
    #samples_c = length(treatment) > samples_cutoff ? 2 : 1 
    println("groupby: $group_label")
    #filter ASVs within a treatment
    gdfs = groupby(asv, "$(group_label)")
    group_ordered = []; gdfs_filter = []
    for gdf in gdfs
        push!(group_ordered, unique(gdf[:, "$(group_label)"]))
        #println("before\t", size(gdf))
        #to keep the process going with the warning below even if there're fewer samples than required.
        samples_c = 2
        if nrow(gdf) >= samples_cutoff
            samples_c = samples_cutoff
        else
            samples_c = nrow(gdf)
            println("Warning: fewer samples than defined under a treatment $(keys(gdf))!")
        end

        select_c = [1,]
        for n in 2:ncol(gdf)-3
            c = (gdf[:, n] .> reads_cutoff ) |> count # more than 'reads_cutoff' reads per sample
            (c >= samples_c) && push!(select_c, n) # 'samples_c' samples at least per treatment if there're many rows still
        end
        gdf = select(gdf, select_c)
        #println("after\t", size(gdf))
        push!(gdfs_filter, gdf)
    end

    return gdfs_filter, group_ordered
end

##extract good ASV based on any taxonomy classifcation and term
function asv_taxa_extract(asv_in, taxa_in, sample_in, treatment, reads_cutoff, samples_cutoff, rank, term)
    (asv_taxa, df_taxa) = df_merger(asv_in, taxa_in, sample_in)
    #CSV.write("taxa.csv", df_taxa)
    (asv_filter_dfs, groups) = asv_filter(asv_taxa, treatment, reads_cutoff, samples_cutoff)
    println("#Groups:\n", groups)
    println("#Number\tASVs")
    #CSV.write("asv_filter.csv", asv_filter_dfs[1])
    gdfs_filter_term = [vcat(gdf, df_taxa, cols=:intersect) for gdf in asv_filter_dfs]
    # CSV.write("BSF10_ASVs-taxa_Immuno.csv", gdfs_filter_term[2])
    # CSV.write("BSF30_ASVs-taxa_Immuno.csv", gdfs_filter_term[3])
    # CSV.write("FM_control_ASVs-taxa_Immuno.csv", gdfs_filter_term[1])

    ## to get the index of one rank
    ranks = ["Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species"]
    rank_i = findfirst(rank .== ranks) #faster and efficient

    ##extract ASVs assinged to a taxonomy term.
    asv_list = Vector{String}[]; #asv_list_c = Vector{String}[]
    for gdf in gdfs_filter_term
        asv_detected = String[]; #asv_detected_c = String[]
        taxa_detected = collect(gdf[end-7+rank_i, :])
        # for n in 2:length(taxa_detected)
        #     if term == taxa_detected[n]
        #         push!(asv_detected, names(gdf)[n])
        #         #[append!(asv_detected_c, repeat([names(gdf)[n],], reads)) for reads in gdf[1:end-7, n]]
        #     end
        # end
        asv_detected = ifelse.(taxa_detected[2:end] .== term, names(gdf)[2:end], missing)
        asv_detected = filter(!ismissing, asv_detected)
        println(length(asv_detected), "\t", asv_detected)
        
        push!(asv_list, asv_detected)
        #push!(asv_list_c, asv_detected_c)
    end
    return asv_list, groups
end

function venn_plot(asv, category, category_label_size, output_file)
    #skip a single ASV group
    length(asv) < 2 && return "Cannot find overlapping ASV between any two groups!"
    ##plot veen diagram using R
    R"""
    if (!require("ggVennDiagram")) install.packages("ggVennDiagram")
    if (!require("ggplot2")) install.packages("ggplot2")
    library(ggVennDiagram); library(ggplot2)

    ggVennDiagram($asv, 
        label_alpha = 0, 
        label_percent_digit = 1,
        category.names = $category,
        edge_size = 0.5,
        set_size = $category_label_size,
    ) + 
    ggplot2::scale_fill_gradient(low="white",high = "red") +
    scale_x_continuous(expand = expansion(mult = c(.11)))
    ggsave($output_file)
    """
end