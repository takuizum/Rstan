data{
    int N; //number of observations
    int P; //number of items
    int D; //number of factors
    int C; //scaling
    int pre [N,P]; //data
    int post[N,P]; //data
}

transformed data{
    vector[D] theta_mean_pre;
    vector[D] theta_scale_pre;
    
    for (d in 1:D) {
        theta_mean_pre[d] = 0;
        theta_scale_pre[d] = 1;
    }
}

parameters{
    cholesky_factor_cov[P,D] alpha;
    ordered[C-1] beta[P];
    corr_matrix[D] theta_corr_pre;
    corr_matrix[D] theta_corr_post;  
    vector[D] theta_pre[N];
    vector[D] theta_post[N];
    vector[D] theta_mean_post;
    vector<lower = 0>[D] theta_scale_post;
}

transformed parameters{
    vector[P] mu_post[N];
    vector[P] mu_pre [N];
    for(n in 1:N){
        mu_pre[n] = alpha*theta_pre[n];
        mu_post[n] = alpha*theta_post[n];
    }
}

model{
    for(n in 1:N){
        for(p in 1:P){
            if(pre[n,p]!=999){
                pre[n,p] ~ ordered_logistic(mu_pre[n][p], beta[p]);
            }
            if(post[n,p]!=999){
                post[n,p] ~ ordered_logistic(mu_post[n][p], beta[p]);
            }
        }
    }
    theta_corr_pre ~ lkj_corr(1);
    theta_corr_post ~ lkj_corr(1);
    theta_pre ~ multi_normal(theta_mean_pre, quad_form_diag(theta_corr_pre, theta_scale_pre));
    theta_post ~ multi_normal(theta_mean_post, quad_form_diag(theta_corr_post, theta_scale_post));
    theta_mean_post ~ normal(0, 1);
    theta_scale_post ~ lognormal(0, 2);
    to_vector(alpha) ~ normal(0,10^2);
    for(p in 1:P) beta[p] ~ normal(0,10^2);
}
