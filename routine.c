/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   routine.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: anagarri@student.42malaga.com <anagarri    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/09/30 17:54:36 by anagarri          #+#    #+#             */
/*   Updated: 2025/10/07 16:23:31 by anagarri@st      ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo.h"

/* MONITORING ROUTINE 🕵️*/

void	*monitor_routine(void *arg)
{
	t_data	*data;

	data = (t_data *)arg;
	while (1)
	{
		if (simulation_finished(data))
			return (NULL);
		if (any_philo_dead(data))
			return (NULL);
		if (check_if_all_ate(data))
		{
			pthread_mutex_lock(&data->death_mutex);
			if (!data->philo_dead)
				data->simulation_is_completed = 1;
			pthread_mutex_unlock(&data->death_mutex);
			return (NULL);
		}
		usleep(500);
	}
	return (NULL);
}

/*PHILOSOPHER'S ROUTINE 🧠*/

void	*philo_routine(void *arg)
{
	t_philo	*philo;

	philo = (t_philo *)arg;
	while (1)
	{
		if (simulation_finished(philo->data))
			break ;
		if(take_forks(philo))
			eat(philo);
		print_locked(philo, "is sleeping");
		ft_usleep(philo->data->time_to_sleep, philo->data);
		print_locked(philo, "is thinking");
	}
	return (NULL);
}
